library(readr)
setwd("/home/fcabla/Documentos/UPM/TFM")

read_TTL_file <- function(path_file, column_names){
  #df <- read.csv(file = path_file, header = FALSE, sep = " ", skip = 1, col.names = column_names)
  df <- read_delim(file = path_file, col_names = column_names, delim = " ", 
                   skip = 1,escape_double=FALSE, escape_backslash=TRUE, quote="\"")
  df <- subset(df, select = c(column_names[1], column_names[3]))
  return(df)
}

write_csv_file <- function(output_path, df){
  write.csv(df, output_path, row.names = FALSE)
}

read_merge_TTL_files <- function(path_file_abstracts, path_file_types, abstracts_col_names, types_col_names, join_col){
  df_abstracts <- read_TTL_file(path_file_abstracts, abstracts_col_names)
  df_types <- read_TTL_file(path_file_types, types_col_names)
  df <- merge(df_abstracts, df_types, by=join_col)
  
  return(df)
}

# remove owl:thing instances here????