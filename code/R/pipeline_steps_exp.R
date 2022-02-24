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
#print('BEGIN EXPERIMENT PP SVM')
#message('BEGIN EXPERIMENT PP SVM')
experiment_file = "code/R/fasttext_model.R"
print('BEGIN EXPERIMENT pipeline FT')
message('BEGIN EXPERIMENT pipeline FT')

print('abstracts')
message('abstracts')
source("code/R/config.R")
use_temp_files = TRUE
use_ne <- FALSE
use_only_ne <- FALSE  
use_preprocessing <- FALSE
use_lower <- FALSE
use_stem <- FALSE
use_stw <-FALSE
print(paste(use_ne,use_only_ne,use_preprocessing))
source(experiment_file)
gc()
print('===========================================================================================')

print('abstracts+NER')
message('abstracts+NER')
source("code/R/config.R")
use_temp_files = TRUE
use_ne <- TRUE
use_only_ne <- FALSE  
use_preprocessing <- FALSE
use_lower <- FALSE
use_stem <- FALSE
use_stw <-FALSE
print(paste(use_ne,use_only_ne,use_preprocessing))
source(experiment_file)
gc()
print('===========================================================================================')

print('abstracts+PP')
message('abstracts+PP')
source("code/R/config.R")
use_temp_files = TRUE
use_ne <- FALSE
use_only_ne <- FALSE  
use_preprocessing <- TRUE
use_lower <- TRUE
use_stem <- TRUE
use_stw <-TRUE
print(paste(use_ne,use_only_ne,use_preprocessing))
source(experiment_file)
gc()
print('===========================================================================================')

print('abstracts+NER+PP')
message('abstracts+NER+PP')
source("code/R/config.R")
use_temp_files = TRUE
use_ne <- TRUE
use_only_ne <- FALSE  
use_preprocessing <- TRUE
use_lower <- TRUE
use_stem <- TRUE
use_stw <-TRUE
print(paste(use_ne,use_only_ne,use_preprocessing))
source(experiment_file)
gc()
print('===========================================================================================')

print('NER')
message('abstracts+NER+PP')
source("code/R/config.R")
use_temp_files = TRUE
use_ne <- TRUE
use_only_ne <- TRUE  
use_preprocessing <- FALSE
use_lower <- FALSE
use_stem <- FALSE
use_stw <-FALSE
print(paste(use_ne,use_only_ne,use_preprocessing))
source(experiment_file)
gc()
print('===========================================================================================')

#print('0.0033')
#message('0.0033')
#source("code/R/config.R")
#use_ne <- TRUE
#use_only_ne <- FALSE  
#use_preprocessing <- TRUE
#use_lower <- FALSE
#use_stw <-FALSE
#use_stem <- FALSE
#use_lemm <- TRUE  
#remove_punctuation <- FALSE
#print(paste(use_ne,use_only_ne,use_preprocessing, use_lemm))
#source(experiment_file)
#gc()
#print('===========================================================================================')
