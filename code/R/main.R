setwd("/home/fcabla/Documentos/UPM/TFM")

source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization.R")

df <- read_TTL_file("datasets/test_abstracts_long.ttl", c("individual","property","abstract", "dot"))
df <- annotate_dataframe(df, 0.3)
process_dataframe(df)

#df <- read_TTL_file("datasets/long_abstracts_en.ttl", c("individual","property","abstract", "dot"))

