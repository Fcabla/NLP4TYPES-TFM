
GS1_path <- "datasets/goldstandard/GS1.nt"
GS2_path <- "datasets/goldstandard/GS2.nt"
GS3_path <- "datasets/goldstandard/GS3.nt"
column_names <- c("individual","property","type", "dot")
#"models/model1m.rds"
#"models/model10k.rds"
#"models/model_full.rds"
model_path <- "models/model10k.rds"

# Read data
gold_standard <- read_TTL_file(GS1_path, column_names)
gold_standard <- rbind(gold_standard, read_TTL_file(GS2_path, column_names))
gold_standard <- rbind(gold_standard, read_TTL_file(GS3_path, column_names))
df <- read_merge_TTL_files(abs_file_path, types_file_path, abs_col_names, typ_col_names, join_by)
df <- subset(df, select = -type)
df_gs <- merge(gold_standard, df, by="individual")
df_gs <- remove_resources_url(df_gs, c("individual", "type"))


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