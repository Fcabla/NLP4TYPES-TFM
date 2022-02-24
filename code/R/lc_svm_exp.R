#setwd("/home/fcabla/Documentos/UPM/TFM")
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

experiment_file = "code/R/main.R"
print('BEGIN EXPERIMENT LEARNING CURVE SVM')
message('BEGIN EXPERIMENT LEARNING CURVE SVM')

#seq(from=0.01666, to=1+0.01666, by=0.01666)
df_sizes = seq(from=0.01666, to=0.33320, by=0.01666)

for(df_size in df_sizes){
  print(paste('size:', df_size))
  message(paste('size:', df_size))
  source("code/R/config.R")
  sample_percentage <- df_size
  print(sample_percentage)
  source(experiment_file)
}