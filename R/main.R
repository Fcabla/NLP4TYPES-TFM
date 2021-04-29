setwd("/home/fcabla/Documentos/UPM/TFM")

source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")
source("code/R/measurements.R")
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
metrics <- evaluate_results(model, te_tdm)
