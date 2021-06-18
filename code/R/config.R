#####################
# Config parameters #
#####################
# en or es
lang <- "en"
print(paste("Using language:",lang,", please check the paths and services are according to the lang selected"))

# Files location and column names
abs_file_path <- paste("datasets/", lang,"/long_abstracts_",lang,".ttl",sep = "")
types_file_path <- paste("datasets/", lang,"/instance_types_",lang,".ttl",sep = "")
abs_col_names <- c("individual","property","abstract", "dot")
typ_col_names <- c("individual","property","type", "dot")
join_by <- "individual"
use_sampled_df <- TRUE
remove_URL <- TRUE
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 1
remove_OWL_thing <- TRUE

# Ontology trees
ont_url <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"
ont_path <- "datasets/dbpedia_2016-10.owl"
path_printable_names <- paste("datasets/", lang,"/printable_names_",lang,".csv",sep = "")

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
use_printable_names <- FALSE

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

# Gold Standard evaluation
use_new_GS <- TRUE
GS1_path <- "datasets/goldstandard/GS1.nt"
GS2_path <- "datasets/goldstandard/GS2.nt"
GS3_path <- "datasets/goldstandard/GS3.nt"
new_GS_path <- "datasets/goldstandard/new/instance_types_lhd_dbo_en.ttl"
column_GS_names <- c("individual","property","type", "dot")
#"models/model1m.rds","models/model10k.rds","models/model_full.rds"
model_path <- paste("models/",lang,"/model1m.rds",sep = "")

# Testing
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."
