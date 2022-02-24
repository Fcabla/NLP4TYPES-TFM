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
print('BEGIN EXPERIMENT PP FT')
message('BEGIN EXPERIMENT PP FT')

print('baseline')
message('baseline')
source("code/R/config.R")
use_lower <- FALSE
use_stw <-FALSE
use_stem <- FALSE
use_lemm <- FALSE  
remove_punctuation <- FALSE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()
print('===========================================================================================')

print('lowerCase')
message('lowerCase')
source("code/R/config.R")
use_lower <- TRUE
use_stw <-FALSE
use_stem <- FALSE
use_lemm <- FALSE  
remove_punctuation <- FALSE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()
print('===========================================================================================')

print('stw')
message('stw')
source("code/R/config.R")
use_lower <- FALSE
use_stw <-TRUE
use_stem <- FALSE
use_lemm <- FALSE  
remove_punctuation <- FALSE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()
print('===========================================================================================')

print('stemm')
message('stemm')
source("code/R/config.R")
use_lower <- FALSE
use_stw <-FALSE
use_stem <- TRUE
use_lemm <- FALSE  
remove_punctuation <- FALSE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()
print('===========================================================================================')

print('lemma')
message('lemma')
source("code/R/config.R")
use_lower <- FALSE
use_stw <-FALSE
use_stem <- FALSE
use_lemm <- TRUE  
remove_punctuation <- FALSE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()
print('===========================================================================================')

print('punct')
message('punct')
source("code/R/config.R")
use_lower <- FALSE
use_stw <-FALSE
use_stem <- FALSE
use_lemm <- FALSE  
remove_punctuation <- TRUE
print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
source(experiment_file)
gc()

#print('stw+stemm')
#source("code/R/config.R")
#use_stw <-TRUE
#use_stem <- TRUE
#use_lemm <- FALSE  
#remove_punctuation <- FALSE
#print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
#source(experiment_file)
#gc()
#print('===========================================================================================')


#print('stw+lemma')
#source("code/R/config.R")
#use_stw <-TRUE
#use_stem <- FALSE
#use_lemm <- TRUE  
#remove_punctuation <- FALSE
#print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
#source(experiment_file)
#gc()
#print('===========================================================================================')

#print('stw+stem+lemma')
#source("code/R/config.R")
#use_stw <-TRUE
#use_stem <- TRUE
#use_lemm <- TRUE  
#remove_punctuation <- FALSE
#print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
#source(experiment_file)
#gc()
#print('===========================================================================================')

#print('stw+punct')
#source("code/R/config.R")
#use_stw <-TRUE
#use_stem <- FALSE
#use_lemm <- FALSE  
#remove_punctuation <- TRUE
#print(paste(use_stw,use_stem,use_lemm,remove_punctuation))
#source(experiment_file)
#gc()
