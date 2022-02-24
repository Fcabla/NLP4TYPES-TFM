if(!exists("EXPERIMENT_MODE")){
  print('Not in sequential experiment mode')
  setwd("/home/fcabla/Documentos/UPM/TFM")
  source("code/R/dbpedia_data.R")
  source("code/R/name_entity.R")
  source("code/R/text_preprocess_vectorization_q.R")
  source("code/R/measurements.R")
  source("code/R/ontology_trees.R")
  library(data.table)
  library(fastText)
  
  # Read config parameters:
  source("code/R/config.R")
}

##################
# Start workflow #
##################
set.seed(7)
start_t <- timestamp()
use_stored_df <- FALSE
if (use_stored_df){
  print("Reading stored df")
  df <- read.csv(file="test_df_ne.csv")
  #df_ne <- read.csv(file="/home/fcabla/Documentos/UPM/TFM/datasets/3mdbpedia_ne.csv")
  #df_ne <- fread("datasets/3mdbpedia_ne.csv")
  #df_ne$X <- NULL
  
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

# 4. Preprocessing
if(use_preprocessing){
  print("4. Using preprocessing before vectorization")
  if(lang == "en"){
    l <- "english"
  }
  if(lang == "es"){
    l <- "spanish"
  }
  df_ne <- preprocess_dataframe_abstracts(df_ne, stw_opt = use_stw, punct_remove = remove_punctuation, lemm_opt = use_lemm, stem_opt = use_stem, custom_sw = custom_stw, language = l, use_low=use_lower)
  #tdm <- process_dataframe(df_ne, stw_opt = use_stw, punct_remove = remove_punctuation, lemm_opt = use_lemm, stem_opt = use_stem, tfidf = use_tfidf, custom_sw =  custom_stw)
}else{
  print("4. Not using preprocessing before vectorization")
}

df_ne$individual <- NULL
df_ne$abstract <- sapply(df_ne$abstract, function(x) { gsub("[\r\n]", "", x) })

# split train test
print("Splitting the dataset")
dt = sort(sample(nrow(df_ne), nrow(df_ne)*.8))
train<-df_ne[dt,]
test<-df_ne[-dt,]
rm(df_ne)
gc()

# ------------- Prepare data -------------
print("preparing the dataset")
exp_time = Sys.time()
print(paste('Start of the experiment at: ', exp_time))

if(use_temp_files){
  print('NOT SAVING THE MODEL NOR THE LOGS')
  tmp_file_model = tempfile()
  logs_supervise = tempfile()
}else{
# Model file:
results_dir_logs <- "ft/outputs"
results_dir_models <- "ft/models"
tmp_file_model <- file.path(results_dir_models, paste('model_nlp4types', exp_time))

# Logs for the model:
logs_supervise = file.path(results_dir_logs, paste('logs_supervise',exp_time, '.txt'))
}

# Train tmp file:
train_labels <- paste0("__label__", train[,"type"])
train_texts <- train[,"abstract"]
train_to_write <- paste(train_labels, train_texts)
train_tmp_file_txt <- tempfile()
writeLines(text = train_to_write, con = train_tmp_file_txt)

# Test tmp file:
test_labels <- paste0("__label__", test[,"type"])
test_labels_without_prefix <- test[,"type"]
test_texts <- test[,"abstract"]
test_to_write <- paste(test_labels, test_texts)
test_tmp_file_txt <- tempfile()
writeLines(text = test_to_write, con = test_tmp_file_txt)

# Result of the prediction:
prediction_results_file = file.path(tempdir(), 'predict_valid.txt')
  
print("begging training")
if(lang == "en"){
  print("english parameters")
  message("english parameters")
  list_params = list(command = 'supervised',
                   lr = 0.08499425639667486,
                   dim=92,
                   ws=5,
                   epoch=100,
                   minCount=1,
                   minCountLabel=0,
                   minn=0,
                   maxn=0,
                   neg=5,
                   wordNgrams=2,
                   loss='softmax',
                   bucket=4110692,
                   thread=3,
                   lrUpdateRate=100,
                   t=0.0001,
                   input = file.path(train_tmp_file_txt),
                   output = file.path(tmp_file_model),
                   verbose = 2,
                   thread = 12)
  # 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
  if(sample_percentage == 0.0033){
    list_params['lr'] = 1.9338204646809385
    list_params['dim'] = 156
    list_params['epoch'] = 65
    list_params['verbose'] = 2
    list_params['wordNgrams'] = 1

  }else if (sample_percentage == 1) {
    #same values as 0.33%
    list_params['verbose'] = 2
  }

}else if (lang == "es"){
  print("spanish parameters")
  message("spanish parameters")
  list_params = list(command = 'supervised',
                 lr = 0.08499425639667486,
                 epoch = 100,
                 dim=92,
                 ws=5,
                 epoch=100,
                 minCount=1,
                 minCountLabel=0,
                 minn=0,
                 maxn=0,
                 neg=5,
                 wordNgrams=2,
                 loss='softmax',
                 bucket=4110692,
                 thread=3,
                 lrUpdateRate=100,
                 t=0.0001,
                 input = file.path(train_tmp_file_txt),
                 output = file.path(tmp_file_model),
                 verbose = 2,
                 thread = 12)

  # 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
  if(sample_percentage == 0.0033){
    list_params['lr'] = 2.9781190680441556
    list_params['dim'] = 97
    list_params['ws'] = 5
    list_params['epoch'] = 100
    list_params['wordNgrams'] = 1

  }else if (sample_percentage == 1) {
    #same values as 0.33%
    list_params['verbose'] = 2
  }
}

res = fasttext_interface(list_params,
                         path_output = file.path(logs_supervise),
                         MilliSecs = 5)
print("end training")

# plot curves
res = plot_progress_logs(path = file.path(logs_supervise), plot = TRUE)
dim(res)

# test performance by t
print("begin testing")
list_params = list(command = 'test',
                   model = paste(file.path(tmp_file_model),".bin", sep=""),
                   test_data = file.path(test_tmp_file_txt),
                   k = 1,
                   th = 0.0)

res = fasttext_interface(list_params)
print(res)

# get predicted labels
list_params = list(command = 'predict',
                     model = paste(file.path(tmp_file_model),".bin", sep=""),
                     test_data = file.path(test_tmp_file_txt),
                     k = 1,
                     th = 0.0)
 
res = fasttext_interface(list_params, 
                           path_output = file.path(prediction_results_file))
#  

predicted <- read.table(file.path(prediction_results_file), header=FALSE, sep="")


predicted$V1 <- sapply(predicted$V1, function(x) { gsub("__label__", "", x) })

metrics <- evaluate_results_dict(predicted$V1, test_labels_without_prefix, path_types_dic)
print(round(metrics,digits = 3))
end_t <- timestamp()

print(paste('Finish experiment: ', exp_time))

print(paste('Experiment started at: ', start_t, ' and ended at: ', end_t))
