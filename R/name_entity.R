library(httr)
library(jsonlite)

# Example
# curl http://localhost:2222/rest/annotate --data-urlencode "text=President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance." --data "confidence=0.35" -H "Accept: application/json"


#DBPEDIA_PATH <- "https://api.dbpedia-spotlight.org/en/annotate"
DBPEDIA_PATH <- "http://localhost:2222/rest/annotate"
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."

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
    Sys.sleep(0.1)
    return(paste(unlist(types), collapse = ' '))
  }else{
    retry_num <- retry_num + 1
    print(paste("failed to name entity raw text, retry number", retry_num, collapse = ' '))
    Sys.sleep(retry_num)
    return(get_types_from_text(raw_text, confidence_lvl, retry_num))
  }
  
}

# Take a dataframe and add to each abstract the entity types extracted by the function get_types_from_text(..)
annotate_dataframe <- function(df, confidence_lvl){
  # dont like this approach (use transform or apply)
  for (row in 1:nrow(df)) {
    df[row, ]$abstract <- paste(df[row, ]$abstract, get_types_from_text(df[row,]$abstract, confidence_lvl), sep = " ")
  }
  #df <- transform(df, abstract = paste(abstract, get_types_from_text(abstract,confidence_lvl), sep = " "))
  #df$test <- paste(x[2], get_types_from_text(x[2],confidence_lvl), sep = " ")
  #apply(df, 1, get_types_from_text, confidence_lvl)
  return(df)
}

# Function to annotate a raw text (inference end user)
annotate_raw_text <- function(raw_text, confidence_lvl){
  result_text <- paste(raw_text, get_types_from_text(raw_text, confidence_lvl), sep = " ")
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
