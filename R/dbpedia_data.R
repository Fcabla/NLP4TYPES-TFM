library(readr)
setwd("/home/fcabla/Documentos/UPM/TFM")

read_TTL_file <- function(path_file, column_names){
  #df <- read.csv(file = path_file, header = FALSE, sep = " ", skip = 1, col.names = column_names)
  df <- read_delim(file = path_file, col_names = column_names, delim = " ", 
                   skip = 1,escape_double=FALSE, escape_backslash=TRUE, quote="\"")
  df <- subset(df, select = c(column_names[1], column_names[3]))
  df <- head(df,-1)
  print(tail(df, 10))
  return(df)
}

write_csv_file <- function(output_path, df){
  write.csv(df, output_path, row.names = FALSE)
}

read_merge_TTL_files <- function(path_file_abstracts, path_file_types, abstracts_col_names, types_col_names, join_col){
  df_abstracts <- read_TTL_file(path_file_abstracts, abstracts_col_names)
  df_types <- read_TTL_file(path_file_types, types_col_names)
  df <- merge(df_abstracts, df_types, by=join_col)
  df <- remove_owl_thing_rows(df)
  return(df)
}

# remove owl:thing instances here????
remove_owl_thing_rows <- function(df){
  df <- df[!grepl("<http://www.w3.org/2002/07/owl#Thing>",df$type),]
  return(df)
}
# https://rstudio-pubs-static.s3.amazonaws.com/223076_ba9864e5b73146e7a184fa8d8f14fc21.html
get_sample_df <- function(df, perc_sample){
  nsample <- perc_sample * nrow(df)
  print(nsample)
  df <- df[sample(nrow(df), nsample), ]
  return(df)
}