setwd("/home/fcabla/Documentos/UPM/TFM")

source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")

library(data.table)
 
#####################
# Config parameters #
#####################
# en or es
lang <- "en"
print(paste("Using language:",lang,", please check the paths and services are according to the lang selected"))
# Files location and column names
#abs_file_path <- "datasets/en/long_abstracts_en.ttl"
#types_file_path <- "datasets/en/instance_types_en.ttl"
abs_file_path <- paste("datasets/", lang,"/long_abstracts_",lang,".ttl",sep = "")
types_file_path <- paste("datasets/", lang,"/instance_types_",lang,".ttl",sep = "")
abs_col_names <- c("individual","property","abstract", "dot")
typ_col_names <- c("individual","property","type", "dot")
join_by <- "individual"
use_sampled_df <- TRUE
remove_URL <- TRUE
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.33

# Name entity
use_ne <- TRUE
use_only_ne <- FALSE  
confidence_lvl <- 0.33
service_url <- DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"
#path_dict_ne <- "datasets/en/types_dict_en.csv"
path_dict_ne <- paste("datasets/", lang,"/types_dict_",lang,".csv",sep = "")
use_only_dict <- TRUE  # To use if the dict contains every individual
dbo_only <- TRUE
use_ne_path2root <- TRUE
use_printable_names <- TRUE

# text preprocessing and vectorization
use_preprocessing <- FALSE
use_stw <-TRUE
custom_stw <- c("@en", "\"@en", "@es", "\"@es")
use_stem <- TRUE
use_lemm <- FALSE  
remove_punctuation <- FALSE # Check if original does it
use_tfidf <- TRUE

# Classification
train_percent <- 0.8
use_crossval <- FALSE
crossval_folds <- 5

# Ontology trees
ont_url <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"
ont_path <- "datasets/dbpedia_2016-10.owl"
path_printable_names <- paste("datasets/", lang,"/printable_names_",lang,".csv",sep = "")
# Measurements

# Testing
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."

##################
# Start workflow #
##################
start_t <- timestamp()
# 1. Read files
print("1. Read Files:")
df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by)
print(paste("    Total num of samples: ", dim(df)[1]))
if(remove_URL){
  print("    Removing URLs from resources/types")
  df <- remove_resources_url(df, c("individual", "type"))
  # RaceHorse not working!
  #df$type[df$type == "RaceHorse"] <- "HorseRace"
}
  
if(use_sampled_df)
  df <- get_sample_df(df, sample_percentage)
print(paste("    Number of instances used in the current experiment: ", dim(df)[1]))

# 2. Get ontology tree
print("2. Retrieve ontology tree")
dbo_tree <- get_tree_from_ontology(resourc = ont_path)

#if(use_printable_names){}
printable_names <- read.csv(path_printable_names, header=TRUE, stringsAsFactors=F)
path_types_dic <- make_path_type_dict(printable_names, dbo_tree)

  
# 3. Name entity
df_ne <- copy(df)
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
   

# 4. preprocess and vectorization
if(use_preprocessing){
  print("4. Using preprocessing before vectorization")
  if(lang == "en"){
    l <- "english"
  }
  if(lang == "es"){
    l <- "spanish"
  }
  df_ne <- preprocess_dataframe_abstracts(df_ne, stw_opt = use_stw, punct_remove = remove_punctuation, lemm_opt = use_lemm, stem_opt = use_stem, custom_sw =  custom_stw, language <- l)
  #tdm <- process_dataframe(df_ne, stw_opt = use_stw, punct_remove = remove_punctuation, lemm_opt = use_lemm, stem_opt = use_stem, tfidf = use_tfidf, custom_sw =  custom_stw)
}
#print("4. Not using preprocessing before vectorization")
#tdm <- process_dataframe(df_ne, stw_opt = FALSE, punct_remove = FALSE, lemm_opt = FALSE, stem_opt = FALSE, tfidf = use_tfidf, custom_sw =  "")
tdm <- vectorizate_dataframe(df_ne, tfidf=use_tfidf)
tdm <- dfm_replace(tdm, pattern = "Bias", replacement = "bias")

# 5. Classifier
rm(df, df_ne, ne_types_df, types_dict)
#.rs.restartR()
if(use_crossval){
  print("5. Build and train classifier with all the data")
  
  #model <- build_train_model(train_data = tdm, labels = tdm$type)
  print("6. Metrics with crossvalidation")
  metrics <- assess_model_cv_tdm(tdm, k = crossval_folds, verbose = TRUE, ont_tree = NULL, dict_paths = paths_types_dic)
  
  print(metrics)
}else{
  print("5. Splitting the data, build and train classifier")
  splitted_df <- split_data_trte(tdm, trte_split = train_percent)
  tr_tdm <- splitted_df[[1]]; te_tdm <- splitted_df[[2]]
  rm(splitted_df)
  gc()
  #model <- build_train_model(train_data = tr_tdm, labels = tr_tdm$type)
  model <- fit_linear_svc(x=tr_tdm, y=tr_tdm$type, weight="uniform")
  rm(tr_tdm)
  gc()
  predicted <- predict_abstracts(model, te_tdm)
  
  # 6. metrics
  print("6. Metrics")
  #metrics <- evaluate_results(predicted, te_tdm$type, dbo_tree)
  metrics <- evaluate_results_dict(predicted, te_tdm$type, path_types_dic)
  print_measurements(metrics)
}



end_t <- timestamp()

print(start_t)
print(end_t)

#df$type <- as.character(df$type)
#tipos <- list()
#for (ty in df$type){
#  tt <- path_types_dic[[ty]]
#  if(is.null(tt)){
#    tipos <- c(tipos, ty)
#  }
#}
# RaceHorse -> HorseRace (NO, THEY ARE DIFFERENT)
# Holiday
