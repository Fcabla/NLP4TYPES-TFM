source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")
library(data.table)
# Read config parameters:
source("code/R/config.R")

library(dplyr)
library(zeallot)
library(reticulate)
set.seed(7)

### INITIAL CONFIG ###
Sys.setenv(TF_KERAS=1) 
reticulate::use_condaenv('r-reticulate', required = TRUE)
reticulate::py_config()
reticulate::py_module_available('keras_bert')
#tensorflow::install_tensorflow(version = 1.15)
tensorflow::tf_version()

pretrained_path = 'models/uncased_L-12_H-768_A-12'
config_path = file.path(pretrained_path, 'bert_config.json')
checkpoint_path = file.path(pretrained_path, 'bert_model.ckpt')
vocab_path = file.path(pretrained_path, 'vocab.txt')

k_bert = import('keras_bert')
token_dict = k_bert$load_vocabulary(vocab_path)
tokenizer = k_bert$Tokenizer(token_dict)

seq_length = 50L
bch_size = 64
epochs = 2
learning_rate = 1e-4

df_COLUMN = 'abstract'
#LABEL_COLUMN = 'type'
LABEL_COLUMN = 'id_type'

model = k_bert$load_trained_model_from_checkpoint(
  config_path,
  checkpoint_path,
  training=T,
  trainable=T,
  seq_len=seq_length)

### LOADING DATA ###

# tokenize text
tokenize_fun = function(dfset) {
  c(indices, target, segments) %<-% list(list(),list(),list())
  for ( i in 1:nrow(dfset)) {
    c(indices_tok, segments_tok) %<-% tokenizer$encode(dfset[[df_COLUMN]][i], 
                                                       max_len=seq_length)
    indices = indices %>% append(list(as.matrix(indices_tok)))
    target = target %>% append(dfset[[LABEL_COLUMN]][i])
    segments = segments %>% append(list(as.matrix(segments_tok)))
  }
  return(list(indices,segments, target))
}

# read df
#dt_df = function(dir, rows_to_read){
dt_df = function(df, rows_to_read){
  #df = df.table::fread(dir, nrows=rows_to_read)
  c(x_train, x_segment, y_train) %<-% tokenize_fun(df)
  return(list(x_train, x_segment, y_train))
}

use_stored_df <- FALSE
if (use_stored_df){
  print("Using stored df of 10k")
  df_ne = readRDS("test_df.rds")
}else{
  df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by, remove_OWL_thing)
  print(paste("    Total num of samples: ", dim(df)[1]))
  
  if(use_sampled_df)
    df <- get_sample_df(df, sample_percentage)
  print(paste("    Number of instances used in the current experiment: ", dim(df)[1]))
  
  if(remove_URL){
    print("    Removing URLs from resources/types")
    df <- remove_resources_url(df, c("individual", "type"))
    # RaceHorse not working!
    #df$type[df$type == "RaceHorse"] <- "HorseRace"
  }
  
  # 2. Get ontology tree
  print("2. Retrieve ontology tree")
  dbo_tree <- get_tree_from_ontology(resourc = ont_path)
  
  #if(use_printable_names){}
  printable_names <- read.csv(path_printable_names, header=TRUE, stringsAsFactors=F)
  path_types_dic <- make_path_type_dict(printable_names, dbo_tree)
  
  
  # 3. Name entity
  df_ne <- copy(df)
  rm(df)
  if(use_ne){
    print("3. Using Name entity dbpedia spotlight")
    types_dict <- NULL
    if(path_dict_ne != ""){
      # Using dictionary
      print("    Using dictionary/cache")
      types_dict <- load_dict(path_dict_ne, remove_URL)
    }
    if(use_only_dict & path_dict_ne != ""){
      ne_types_df <- annotate_dataframe_dict(df_ne, types_dict, dbo_only = dbo_only, use_ne_path2root = use_ne_path2root, dbo_tree = dbo_tree, path_types_dic = path_types_dic,printable_names = use_printable_names, printable_names_df = printable_names)
    }else{
      ne_types_df <- annotate_dataframe(df_ne, confidence_lvl, types_dict = types_dict, dbo_only = dbo_only, use_ne_path2root = use_ne_path2root, dbo_tree = dbo_tree, printable_names = use_printable_names, printable_names_df = printable_names)
    }
    
    df_ne <- merge(df_ne, ne_types_df, by="individual")
    if(use_only_ne){
      df_ne$abstract <- df_ne$ne_types
    }else{
      df_ne$abstract <- paste(df_ne$abstract, df_ne$ne_types, sep=" ")
    }
    df_ne <- subset(df_ne, select = -ne_types)
    
  }else{
    print("3. Not using Name entity dbpedia spotlight")
  }
}

dunique = get_unique_types(df_ne)
df_ne = encode_df_types(df_ne, dunique)
df_ne$id_type = df_ne$id_type-1
df_ne$abstract <- lapply(df_ne$abstract, function(x){substring(x, 1, 512)})
df_ne$abstract <- as.character(df_ne$abstract)
#c(x_train,x_segment, y_train) %<-% dt_df('test_df_ne.csv',10000)

c(x_train,x_segment, y_train) %<-% dt_df(df_ne,10000)

train = do.call(cbind,x_train) %>% t()
segments = do.call(cbind,x_segment) %>% t()
targets = do.call(cbind,y_train) %>% t()

concat = c(list(train ),list(segments))

c(decay_steps, warmup_steps) %<-% k_bert$calc_train_steps(
  targets %>% length(),
  batch_size=bch_size,
  epochs=epochs
)

#num_classes = length(unique(df_ne$type))
num_classes = length(unique(df_ne$id_type))
library(keras)

input_1 = get_layer(model,name = 'Input-Token')$input
input_2 = get_layer(model,name = 'Input-Segment')$input
inputs = list(input_1,input_2)

dense = get_layer(model,name = 'NSP-Dense')$output

#outputs = dense %>% layer_dense(units=1L, activation='sigmoid',kernel_initializer=initializer_truncated_normal(stddev = 0.02),name = 'output')
outputs = dense %>% layer_dense(units=num_classes, activation='softmax', 
                                kernel_initializer=initializer_truncated_normal(stddev = 0.02),
                                name = 'output')
model = keras_model(inputs = inputs,outputs = outputs)

opt = k_bert$AdamWarmup(decay_steps=decay_steps,warmup_steps=warmup_steps, learning_rate=learning_rate)

model %>% compile(opt, loss = 'sparse_categorical_crossentropy', metrics = 'accuracy')

hits = model %>% fit(
  concat,
  targets,
  epochs=epochs,
  batch_size=bch_size, validation_split=0.25)
print(hits)
#model$fit(concat, targets, epochs=epochs, batch_size=bch_size, validation_split=0.2)

