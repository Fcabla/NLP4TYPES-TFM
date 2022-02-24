# Read config parameters:
setwd("/home/fcabla/Documentos/UPM/TFM")
source("code/R/dbpedia_data.R")
source("code/R/name_entity.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/measurements.R")
source("code/R/ontology_trees.R")
source("code/R/config.R")
library(data.table)
library(fastText)

# Read config parameters:
source("code/R/config.R")
# Read data
if(use_new_GS){
  gold_standard <- read_TTL_file(new_GS_path, column_GS_names)
}else{
  gold_standard <- read_TTL_file(GS1_path, column_GS_names)
  gold_standard <- rbind(gold_standard, read_TTL_file(GS2_path, column_GS_names))
  gold_standard <- rbind(gold_standard, read_TTL_file(GS3_path, column_GS_names))
}
print(paste(dim(gold_standard)[1], " instances before joining with abstracts"))
#length(unique(gold_standard$individual))
df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by)
df <- subset(df, select = -type)
df_gs <- merge(gold_standard, df, by="individual")
if(remove_URL){
  df_gs <- remove_resources_url(df_gs, c("individual", "type"))
}
df_gs <- df_gs[!duplicated(df_gs$individual),]

# try to fix old types
if(!use_new_GS){
  df_gs$type[df_gs$type == "Comics"] <- "Comic"
  #df_gs[df_gs == "Comics"] <- "Comic"
}
print(paste(dim(df_gs)[1], " instances after joining with abstracts"))
print(paste(length(unique(df_gs$type)), " unique classes"))
rm(df)

# Read ontology
dbo_tree <- get_tree_from_ontology(resourc = ont_path)
printable_names <- read.csv(path_printable_names, header=TRUE, stringsAsFactors=F)
path_types_dic <- make_path_type_dict(printable_names, dbo_tree)

# prepare test data
df_gs$abstract <- sapply(df_gs$abstract, function(x) { gsub("[\r\n]", "", x) })
#tmp_file_model <- 'ft/models/model_en_ft_3m'
tmp_file_model <- paste(tmp_file_model, '.bin', sep='')
test_labels <- paste0("__label__", df_gs[,"type"])
test_labels_without_prefix <- df_gs[,"type"]
test_texts <- df_gs[,"abstract"]
test_to_write <- paste(test_labels, test_texts)
test_tmp_file_txt <- tempfile()
writeLines(text = test_to_write, con = test_tmp_file_txt)
prediction_results_file = file.path(tempdir(), 'predict_valid.txt')

# test performance by t
print("begin testing")
list_params = list(command = 'test',
                   model = tmp_file_model,
                   test_data = file.path(test_tmp_file_txt),
                   k = 1,
                   th = 0.0)

res = fasttext_interface(list_params)
print(res)

# get predicted labels
list_params = list(command = 'predict',
                   model = file.path(tmp_file_model),
                   test_data = file.path(test_tmp_file_txt),
                   k = 1,
                   th = 0.0)

res = fasttext_interface(list_params, 
                         path_output = file.path(prediction_results_file))
#  

predicted <- read.table(file.path(prediction_results_file), header=FALSE, sep="")
predicted$V1 <- sapply(predicted$V1, function(x) { gsub("__label__", "", x) })
metrics <- evaluate_results_dict(predicted$V1, test_labels_without_prefix, path_types_dic)
print(round(metrics,digits = 3))
