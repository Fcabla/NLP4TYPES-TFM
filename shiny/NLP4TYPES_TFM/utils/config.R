#####################
# Config parameters #
#####################
# en or es
lang <- "en"
print(paste("Using language:",lang,", please check the paths and services are according to the lang selected"))

# Ontology trees
#ont_path <- "datasets/dbpedia_2016-10.owl"
path_printable_names <- paste("datasets/", lang,"/printable_names_",lang,".csv",sep = "")

# Name entity
use_ne <- TRUE
use_only_ne <- FALSE  
confidence_lvl <- 0.33
#service_url <- DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"
#API works fine for single inference (user inference)
service_url <- DBPEDIA_PATH <- "https://api.dbpedia-spotlight.org/en/annotate"
path_dict_ne <- paste("datasets/", lang,"/types_dict_",lang,".csv",sep = "")
dbo_only <- TRUE
use_ne_path2root <- FALSE
use_printable_names <- FALSE

# text preprocessing and vectorization
use_preprocessing <- FALSE
use_stw <-TRUE
custom_stw <- c("@en", "\"@en", "@es", "\"@es")
use_stem <- TRUE
use_lemm <- FALSE  
remove_punctuation <- FALSE # Check if original does it
use_tfidf <- FALSE  # TFIDF IS A NO SENSE WITH 1 DOCUMENT. 
#Either we recover the frequency of the previous features and the unweighted matrix to re-weight every run or we just use TF

# Unseen pred
model_path <- paste("models/",lang,"/model10k.rds",sep = "")
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."
