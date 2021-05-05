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
abstracts_file_path <- ""
types_file_path <- ""
abstracts_col_names <- ""
types_col_names <- ""

# Name entity
use_ne <- TRUE
use_only_ne <- FALSE  # ToDo: return only ne types
confidence_lvl <- 0.3
service_url <- DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"

# text preprocessing and vectorization
use_preprocessing <- TRUE
custom_stopwords <- c("@en", "\"@en")
use_stem <- TRUE
use_lemm <- FALSE  # ToDo: add lemmatization
remove_punctuation <- TRUE # Check if original does it
use_tfidf <- TRUE

# Classification
trte_split <- 0.8
use_crossval <- TRUE
crossval_folds <- 5

# Ontology trees
DBO_URL <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"
ontology_from_URL=TRUE # Finish

# Measurements

# Testing
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."

####################################################################################################
# Read both ttl files and store a sample of the merged files to do the developing with a smaller df
####################################################################################################

#df <- read_TTL_file("datasets/test_abstracts_long.ttl", c("individual","property","abstract", "dot"))
#df <- read_merge_TTL_files("datasets/long_abstracts_en.ttl", "datasets/instance_types_en.ttl", c("individual","property","abstract", "dot"), c("individual","property","type", "dot"), "individual")
#df <- get_sample_df(df, 0.0001)
#df <- annotate_dataframe(df, 0.3)
#write_csv_file("datasets/abstracts_types_annotated_short.csv", df)

####################
# Initial dataflow, developing with a smaller dataframe
####################
df <- read.csv("datasets/abstracts_types_annotated_short.csv", stringsAsFactors = FALSE)
# Encode types to perform classification with certain classification libraries
#df_unique_types <- get_unique_types(df)
#df <- encode_df_types(df, df_unique_types)
df <- annotate_dataframe(df, 0.3)
tdm <- process_dataframe(df, custom_sw = c("@en", "\"@en"))
splitted_df <- split_data_trte(tdm, trte_split = 0.75)
tr_tdm <- splitted_df[[1]]; te_tdm <- splitted_df[[2]]
model <- build_train_model(tr_tdm, crossvalidation=FALSE, k_crossval=5)
predicted <- predict_abstracts(model, te_tdm)
dbo_tree <- get_tree_from_ontology(ontology_from_URL=TRUE)
metrics <- evaluate_results(predicted, te_tdm, dbo_tree)
print_measurements(metrics)
# ToDo: out sample classification, unseen data, final user...

predict_new_text <- function(raw_text, model){
  txt <- annotate_raw_text(raw_text, 0.3)
  new_tdm <- process_text(test, custom_sw = c("@en", "\"@en"))
  results <- predict(model, newdata = test1, type="class")
  return(results)
}