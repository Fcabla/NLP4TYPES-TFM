setwd("/home/fcabla/Documentos/UPM/TFM")

source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")

#####################
# Config parameters #
#####################
# Files location and column names
abs_file_path <- "datasets/long_abstracts_en.ttl"
types_file_path <- "datasets/instance_types_en.ttl"
abs_col_names <- c("individual","property","abstract", "dot")
typ_col_names <- c("individual","property","type", "dot")
join_by <- "individual"
use_sampled_df <- TRUE
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.33

# Name entity
use_ne <- TRUE
use_only_ne <- FALSE  # ToDo: return only ne types
confidence_lvl <- 0.33
service_url <- DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"

# text preprocessing and vectorization
use_preprocessing <- TRUE
use_stw <-TRUE
custom_stw <- c("@en", "\"@en")
use_stem <- FALSE
use_lemm <- TRUE  
remove_punctuation <- TRUE # Check if original does it
use_tfidf <- TRUE

# Classification
train_percent <- 0.8
use_crossval <- TRUE
crossval_folds <- 5

# Ontology trees
DBO_URL <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"
ontology_from_URL=TRUE # Finish

# Measurements

# Testing
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."

##################
# Start workflow #
##################
# 1. Read files
df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by)
print(paste("Total num of samples: ", dim(df)[1]))
if(use_sampled_df)
  df <- get_sample_df(df, sample_percentage)
  print(paste("Number of instances used in the current experiment: ", dim(df)[1]))
  
# 2. Name entity
if(use_ne)
  df <- annotate_dataframe(df, confidence_lvl, use_only_ne) 

# 3. preprocess and vectorization
if(use_preprocessing){
  tdm <- process_dataframe(df, stw_opt = use_stw, punct_remove = remove_punctuation, lemm_opt = use_lemm, stem_opt = use_stem, tfidf = use_tfidf, custom_sw =  custom_stw)
}else{
  tdm <- process_dataframe(df, stw_opt = FALSE, punct_remove = FALSE, lemm_opt = FALSE, stem_opt = FALSE, tfidf = use_tfidf, custom_sw =  "")
}

# 4. Classifier
splitted_df <- split_data_trte(tdm, trte_split = train_percent)
tr_tdm <- splitted_df[[1]]; te_tdm <- splitted_df[[2]]
model <- build_train_model(tr_tdm, crossvalidation=use_crossval, k_crossval=crossval_folds)
predicted <- predict_abstracts(model, te_tdm)

# 5. Ontology tree and metrics
dbo_tree <- get_tree_from_ontology(ontology_from_URL=TRUE)
metrics <- evaluate_results(predicted, te_tdm, dbo_tree)
print_measurements(metrics)

####################################################################################################
# Read both ttl files and store a sample of the merged files to do the developing with a smaller df
####################################################################################################

#df <- read_TTL_file("datasets/test_abstracts_long.ttl", c("individual","property","abstract", "dot"))
#df <- read_merge_TTL_files("datasets/long_abstracts_en.ttl", "datasets/instance_types_en.ttl", c("individual","property","abstract", "dot"), c("individual","property","type", "dot"), "individual")
#df <- get_sample_df(df, 0.0001)
#df <- annotate_dataframe(df, 0.3)
#write_csv_file("datasets/abstracts_types_annotated_short.csv", df)

predict_new_text <- function(raw_text, model){
  txt <- annotate_raw_text(raw_text, 0.3)
  new_tdm <- process_text(test, custom_sw = c("@en", "\"@en"))
  results <- predict(model, newdata = test1, type="class")
  return(results)
}