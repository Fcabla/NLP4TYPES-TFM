setwd("/home/fcabla/Documentos/UPM/TFM")

source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")
library(data.table)

# Read config parameters:
source("code/R/config.R")

##################
# Start workflow #
##################
set.seed(7)
start_t <- timestamp()
# 1. Read files
print("1. Read Files:")
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
}else{
  print("4. Not using preprocessing before vectorization")
}

print("start experiment")

mterm <- c(0.10, 0.20, 0.30, 0.4, 0.5, 0.6, 0.7)
#mdoc <- c(0.1, 0.2, 0.3)
mdoc <- c(1)
for (min_doc in mdoc) {
  for (min_term in mterm) {
    min_doc <- NULL
    print(paste("min_doc:", min_doc, "min_term:", min_term, sep = " "))
    tdm <- vectorizate_dataframe(df_ne, tfidf=use_tfidf, trim_tdm, min_term, min_doc)
    tdm <- dfm_replace(tdm, pattern = "Bias", replacement = "bias")
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
    
    metrics <- evaluate_results_dict(predicted, te_tdm$type, path_types_dic)
    print(round(metrics,digits = 3))
    print("-----------------------")
  }
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
