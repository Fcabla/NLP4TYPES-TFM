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
print('BEGIN building models FT')
message('BEGIN building models FT')

print('0.0033 en')
message('0.0033 en')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.0033
lang <- "en"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')

print('0.33 en')
message('0.33 en')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.33
lang <- "en"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')

print('1 en')
message('1 en')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 1
lang <- "en"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')

print('===========================================================================================')
print('===========================================================================================')

print('0.0033 es')
message('0.0033 es')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.0033
lang <- "es"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')

print('0.33 es')
message('0.33 es')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 0.33
lang <- "es"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')

print('1 es')
message('1 es')
source("code/R/config.R")
# 1 -> 3M, 0.33 -> 1M, 0.0033 -> 10k
sample_percentage <- 1
lang <- "es"
use_temp_files = FALSE
use_preprocessing <- FALSE
use_ne <- TRUE
use_only_ne <- FALSE  
print(paste(use_preprocessing,use_ne,use_only_ne, use_temp_files))
source(experiment_file)
gc()
print('===========================================================================================')