setwd("/home/fcabla/Documentos/UPM/TFM")
source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")
library(data.table)
library(fastText)

set.seed(7)
EXPERIMENT_MODE = TRUE

#experiment_file = "code/R/main.R"
#print('BEGIN EXPERIMENT NE SVM')
#message('BEGIN EXPERIMENT NE SVM')
experiment_file = "code/R/fasttext_model.R"
print('BEGIN EXPERIMENT PP FT')
message('BEGIN EXPERIMENT PP FT')

print('baseline')
message('baseline')
source("code/R/config.R")
use_lower <- TRUE
print(paste(use_only_ne,use_ne_path2root,use_printable_names))
source("code/R/fasttext_model.R")
gc()
print('===========================================================================================')

print('use_printable_names')
message('use_printable_names')
source("code/R/config.R")
use_lower <- FALSE
use_printable_names <- TRUE 
use_ne_path2root <- FALSE
print(paste(use_only_ne,use_ne_path2root,use_printable_names))
source("code/R/fasttext_model.R")
gc()
print('===========================================================================================')

print('use_ne_path2root')
message('use_ne_path2root')
source("code/R/config.R")
use_lower <- FALSE
use_printable_names <- FALSE 
use_ne_path2root <- TRUE  
print(paste(use_only_ne,use_ne_path2root,use_printable_names))
source("code/R/fasttext_model.R")
gc()
print('===========================================================================================')

print('use_ne_path2root+use_printable_names')
message('use_ne_path2root+use_printable_names')
source("code/R/config.R")
use_lower <- FALSE
use_printable_names <- TRUE  
use_ne_path2root <- TRUE
print(paste(use_only_ne,use_ne_path2root,use_printable_names))
source("code/R/fasttext_model.R")
gc()
print('===========================================================================================')

#use_only_ne <- FALSE  
#use_ne_path2root <- FALSE
#use_printable_names <- FALSE