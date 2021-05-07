library(httr)
library(jsonlite)

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
    types <- data$Resources$"@types"
    # get only the dbpedia data
    #types <- regmatches(types, gregexpr("DBpedia:[a-zA-Z]*", types))
    types <- regmatches(types, gregexpr("(?<=DBpedia:)[a-zA-Z]*", types, perl = TRUE))
    #Sys.sleep(0.2)
    return(paste(unlist(types), collapse = ' '))
  }else{
    print(status_code(request))
    return(" ")
    #retry_num <- retry_num + 1
    #print(paste("failed to name entity raw text, retry number", retry_num, collapse = ' '))
    #Sys.sleep(0.2*retry_num)
    return(get_types_from_text(raw_text, confidence_lvl, retry_num))
  }
  
}

# Take a dataframe and add to each abstract the entity types extracted by the function get_types_from_text(..)
# dont like this approach (use transform or apply)
annotate_dataframe <- function(df, confidence_lvl, use_only_ne){
  total_rows <- nrow(df)
  pb <- txtProgressBar(min = 0, max = total_rows, style = 3)
  if(use_only_ne){
    # Return only the type of entities
    for (row in 1:total_rows) {
      df[row, ]$abstract <- get_types_from_text(df[row,]$abstract, confidence_lvl)
      #print(paste(row,"/",nrow(df)))
      setTxtProgressBar(pb, row)
    }
  }else{
    # Return abstracts + type of entities
    for (row in 1:total_rows) {
      df[row, ]$abstract <- paste(df[row, ]$abstract, get_types_from_text(df[row,]$abstract, confidence_lvl), sep = " ")
      #print(paste(row,"/",nrow(df)))
      setTxtProgressBar(pb, row)
    }
  }
  close(pb)
  #df <- transform(df, abstract = paste(abstract, get_types_from_text(abstract,confidence_lvl), sep = " "))
  #df$test <- paste(x[2], get_types_from_text(x[2],confidence_lvl), sep = " ")
  #apply(df, 1, get_types_from_text, confidence_lvl)
  return(df)
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

# Not used right now (testing)
annotate_row <- function(x, confidence_lvl){
  x[2] <- paste(x[2], get_types_from_text(x[2],confidence_lvl), sep = " ")
  return(x)
}

#t <- get_types_from_text(test_text, 0.3)
#request$status_code
#response <- content(request, as = "text", encoding = "UTF-8")
