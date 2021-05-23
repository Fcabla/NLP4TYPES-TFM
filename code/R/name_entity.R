library(httr)
library(jsonlite)
library(data.table)

# Example
# curl http://localhost:2222/rest/annotate --data-urlencode "text=President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance." --data "confidence=0.35" -H "Accept: application/json"

#DBPEDIA_PATH <- "https://api.dbpedia-spotlight.org/en/annotate"
DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"

# Function to get the entity types of a raw text with a certain confidence level.
# Returns the entity types as a concatenated text with spaces
get_types_from_text <- function(raw_text, confidence_lvl, retry_num = 0){
  request <- GET(url = DBPEDIA_PATH, query = list(text = raw_text, confidence = confidence_lvl))
  if(status_code(request) == 200){
    data = fromJSON(rawToChar(request$content))
    resources_types <- data$Resources$"@types"
    # Remove no types
    resources_types <- resources_types[resources_types != ""]
    # get only the dbpedia data
    #types <- regmatches(types, gregexpr("DBpedia:[a-zA-Z]*", types))
    #dbo_types <- regmatches(resources_types, gregexpr("(?<=DBpedia:)[a-zA-Z]*", resources_types, perl = TRUE))
    #dbo_types <- paste(unlist(dbo_types), collapse = ' ')
    #all_types <- paste(unlist(resources_types), collapse = ',')
    all_types <- paste(unlist(resources_types), collapse = ' ')
    # all_types <- paste(unlist(strsplit(l, ",")), collapse = ' ')
    all_types <- strsplit(all_types, ",")
    return(all_types)
  }else{
    # 414 --> query too long | 400
    #print(status_code(request))
    return("")
    #retry_num <- retry_num + 1
    #print(paste("failed to name entity raw text, retry number", retry_num, collapse = ' '))
    #Sys.sleep(0.2*retry_num)
    return(get_types_from_text(raw_text, confidence_lvl, retry_num))
  }
}

# Take a dataframe and add to each abstract the entity types extracted by the function get_types_from_text(..)
# dont like this approach (use transform or apply)

annotate_dataframe <- function(df, confidence_lvl=0.33, dbo_only=TRUE, use_ne_path2root = FALSE, dbo_tree=NULL, printable_names=FALSE, printable_names_df = NULL){
  total_rows <- nrow(df)
  total_not_found <- 0
  ne_types_df <- data.frame(individual=df$individual, ne_types=character(num_new_rows))
  if(printable_names){
    # opt1 split by uppercase -> not working for esp
    pr_names_dict <- printable_names_df$class_name
    names(pr_names_dict) <- printable_names_df$class_ontology_name
  }
  reuse_dict <- !is.null(types_dict)
  pb <- txtProgressBar(min = 0, max = total_rows, style = 3)
  
  for (row in 1:total_rows) {
    row_ind <- df$individual[row]
    row_abs <- df$abstract[row]
    individual_found <- FALSE
    
    if(reuse_dict){
      # search in dict
      dict_row <- types_dict[.(row_ind), nomatch = 0L]
      #dict_row <- types_dict[row_ind]

      #Check if not found
      if(dim(dict_row)[1] > 0){
        #Check if found but no length
        if(dict_row[[1,2]] != ""){
          individual_found <- TRUE
        }
      }
    }
    
    if(individual_found){
      ne_types <- dict_row[[1,2]]
      #ne_types <- strsplit(ne_types, " ")
      #ne_types <- unlist(ne_types)
      
    }else{
      # print(paste(row_ind, " not found"))
      total_not_found <- total_not_found + 1
      ne_types <- get_types_from_text(df[row,]$abstract, confidence_lvl)
    }
    
    if(dbo_only){
      ne_types <- regmatches(ne_types, gregexpr("(?<=DBpedia:)[a-zA-Z0-9]*", ne_types, perl = TRUE))
      #ne_types <- ne_types[ne_types != ""]
    }else{
      #remove everything before :
      ne_types <- regmatches(ne_types, gregexpr("(?<=:)[a-zA-Z0-9]*", ne_types, perl = TRUE))
    }
    
    if(use_ne_path2root){
      # get path
      ne_types <- sapply(ne_types, find_types_path)
    }
    
    if(printable_names){
      t <- c()
      for(tyname in ne_types){
        better_name <- unname(pr_names_dict[tyname])
        if(is.na(better_name)){
          t <- c(t,tyname)
        }else{
          t <- c(t,better_name)
        }
      }
      ne_types <- t
    }
    # check if lists in lists
    
    ne_types <- paste(unlist(ne_types), collapse = ' ')
    ne_types_df$ne_types[row] <- ne_types
    setTxtProgressBar(pb, row)
  }
  close(pb)
  print(paste("The number of resources not found and queried: ", total_not_found))
  #df <- transform(df, abstract = paste(abstract, get_types_from_text(abstract,confidence_lvl), sep = " "))
  #df$test <- paste(x[2], get_types_from_text(x[2],confidence_lvl), sep = " ")
  #apply(df, 1, get_types_from_text, confidence_lvl)
  return(ne_types_df)
}

annotate_dataframe_dict <- function(df, types_dict, dbo_only=TRUE, use_ne_path2root = FALSE, dbo_tree=NULL, printable_names=FALSE, printable_names_df = NULL){
  ne_types_df <- copy(types_dict)
  ne_types_df <- merge(x=df, y=ne_types_df, by="individual", all.x = TRUE)
  ne_types_df <- data.frame(individual=ne_types_df$individual, ne_types=ne_types_df$all_types, stringsAsFactors = FALSE)
  
  if(dbo_only){
    ne_types_df$ne_types <- regmatches(ne_types_df$ne_types, gregexpr("(?<=DBpedia:)[a-zA-Z]*", ne_types_df$ne_types, perl = TRUE))
    #ne_types$all_types <- ne_types$all_types[ne_types$all_types != ""]
  }else{
    # remove everything before :
    ne_types_df$ne_types <- regmatches(ne_types_df$ne_types, gregexpr("(?<=:)[a-zA-Z0-9]*", ne_types_df$ne_types, perl = TRUE))
    #ne_types_df$ne_types <- strsplit(ne_types_df[[2]],split=" ")
  }
  if(use_ne_path2root){
    # not done yet
    ne_types_df$ne_types <- sapply(ne_types_df$ne_types, find_types_path, ont_tree=dbo_tree)
  }
  
  if(printable_names){
    # opt1 split by uppercase -> not working for esp
    pr_names_dict <- printable_names_df$class_name
    names(pr_names_dict) <- printable_names_df$class_ontology_name
    
    better_names <- function(x, dict){
      t <- character(0)
      for(tyname in x){
        better_name <- unname(pr_names_dict[tyname])
        if(is.na(better_name)){
          t <- c(t,tyname)
        }else{
          t <- c(t,better_name)
        }
      }
      x <- t
    }
    ne_types_df$ne_types <- sapply(ne_types_df$ne_types, better_names, dict=pr_names_dict)
    
  }
  f <- function(x){
    paste(unlist(x), collapse = ' ')
  }
  
  ne_types_df$ne_types <- sapply(ne_types_df$ne_types, f)
  #maybe change name all_types
  #setnames(ne_types, "individual", "ne_types")
  return(ne_types_df)
}
  
# Function to annotate a raw text (inference end user)
annotate_raw_text <- function(raw_text, confidence_lvl, use_only_ne){
  if(use_only_ne){
    result_text <- get_types_from_text(raw_text, confidence_lvl)
  }else{
    result_text <- paste(raw_text, get_types_from_text(raw_text, confidence_lvl), sep = " ")
  }
  return(result_text)
}

# Function to load a cache o dictionary with the ne types of the abstracts per individual
load_dict <- function(path_dict_ne, remove_URL){
  types_dict_df <- read.csv(path_dict_ne, header=TRUE, stringsAsFactors=F)
  if(remove_URL){
    types_dict_df <- remove_resources_url(types_dict_df, c("individual"))
  }
  types_dict <- setDT(types_dict_df)
  setkey(types_dict, individual)
  #types_dict$individual <- gsub("<http://dbpedia.org/(resource|ontology)/(.*)>", "\\2", types_dict$individual)
  return(types_dict)
}

make_dict <- function(start_row, end_row, df, out_path){
  num_new_rows <- (end_row-start_row) + 1 
  df_dict <- data.frame(individual=df[start_row:end_row, ]$individual, all_types=character(num_new_rows), dbo_types=character(num_new_rows))
  pb <- txtProgressBar(min = 0, max = num_new_rows, style = 3)
  for (row in start_row:end_row){
    result_types <- get_types_from_text(df[row,]$abstract, confidence_lvl=0.33)
    df_dict$all_types[row] <- result_types$all_types
    df_dict$dbo_types[row] <- result_types$dbo_types
    setTxtProgressBar(pb, row)
  }
  close(pb)
  write.csv(df_dict, out_path, row.names = FALSE)
  return(df_dict)
}
