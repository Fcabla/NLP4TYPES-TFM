library(readr)
setwd("/home/fcabla/Documentos/UPM/TFM")

# Read a TTL file (using read_delim) and return a dataframe
read_TTL_file <- function(path_file, column_names){
  #df <- read.csv(file = path_file, header = FALSE, sep = " ", skip = 1, col.names = column_names)
  df <- read_delim(file = path_file, col_names = column_names, delim = " ", 
                   skip = 1,escape_double=FALSE, escape_backslash=TRUE, quote="\"")
  df <- subset(df, select = c(column_names[1], column_names[3]))
  df <- head(df,-1)
  return(df)
}

# Save a dataframe in a csv file
write_csv_file <- function(output_path, df){
  write.csv(df, output_path, row.names = FALSE)
}

# Read two TTL files and return a dataframe with the merged files
read_merge_TTL_files <- function(path_file_abstracts, path_file_types, abstracts_col_names, types_col_names, join_col){
  df_abstracts <- read_TTL_file(path_file_abstracts, abstracts_col_names)
  df_types <- read_TTL_file(path_file_types, types_col_names)
  df <- merge(df_abstracts, df_types, by=join_col)
  df <- remove_owl_thing_rows(df)
  return(df)
}

# Remove instances of a dataframe that contain owl#Thing as a type
remove_owl_thing_rows <- function(df){
  # remove owl:thing instances here????
  df <- df[!grepl("<http://www.w3.org/2002/07/owl#Thing>",df$type),]
  return(df)
}

# Take the original dataframe and return a sample of it
get_sample_df <- function(df, perc_sample){
  nsample <- perc_sample * nrow(df)
  df <- df[sample(nrow(df), nsample), ]
  return(df)
} 

# Extract from a dataframe a set of types that are unique, 1 instance per type of type (not used now)
get_unique_types <- function(df){
  df_unique_types <- data.frame(type = unique(df$type))
  df_unique_types$id_type <- seq.int(nrow(df_unique_types))
  return(df_unique_types)
}

# Replace the types as text for an index from the unique set of types (not used now)
encode_df_types <- function(df, df_unique_types){
  df <- merge(df, df_unique_types)
  df <- subset(df, select = -type)
  return(df)
}

remove_resources_url <- function(df, df_columns){
  for (cl in df_columns){
    df[[cl]] <- gsub("<http://dbpedia.org/(resource|ontology)/(.*)>", "\\2", df[[cl]])
    #<http:\/\/dbpedia\.org\/(resource|ontology)\/(.*)>
    # 1st group \\1 captures resource or ontology, 2nd group captures the type or individual
  }
  return(df)
}


# https://rstudio-pubs-static.s3.amazonaws.com/223076_ba9864e5b73146e7a184fa8d8f14fc21.html