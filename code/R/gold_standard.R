# Read config parameters:
source("code/R/dbpedia_data.R")
source("code/R/ontology_trees.R")
source("code/R/text_preprocess_vectorization_q.R")
source("code/R/classifiers.R")

# Read data
if(use_new_GS){
  gold_standard <- read_TTL_file(new_GS_path, column_GS_names)
}else{
  gold_standard <- read_TTL_file(GS1_path, column_GS_names)
  gold_standard <- rbind(gold_standard, read_TTL_file(GS2_path, column_GS_names))
  gold_standard <- rbind(gold_standard, read_TTL_file(GS3_path, column_GS_names))
}
print(paste(dim(gold_standard)[1], " instances before joining with abstracts"))
length(unique(gold_standard$individual))
df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by)
df <- subset(df, select = -type)
df_gs <- merge(gold_standard, df, by="individual")
if(remove_URL){
  df_gs <- remove_resources_url(df_gs, c("individual", "type"))
}
df_gs <- df_gs[!duplicated(df_gs$individual),]
print(paste(dim(df_gs)[1], " instances after joining with abstracts"))
rm(df)

# Read ontology
dbo_tree <- get_tree_from_ontology(resourc = ont_path)
printable_names <- read.csv(path_printable_names, header=TRUE, stringsAsFactors=F)
path_types_dic <- make_path_type_dict(printable_names, dbo_tree)

# Load model
model <- readRDS(model_path)

# vectorizate
tdm <- vectorizate_dataframe(df_gs, tfidf=use_tfidf)
tdm <- dfm_replace(tdm, pattern = "Bias", replacement = "bias")
tdm <- dfm_match(tdm, featnames(model$x))

# evaluate
predicted <- predict_abstracts(model, tdm)
metrics <- evaluate_results_dict(predicted, tdm$type, path_types_dic)
print(round(metrics, digits=3))