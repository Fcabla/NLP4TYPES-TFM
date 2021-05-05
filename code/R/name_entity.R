library(httr)
library(jsonlite)

DBPEDIA_PATH <- "https://api.dbpedia-spotlight.org/en/annotate"
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."

get_types_from_text <- function(raw_text, confidence_lvl){
  request <- GET(url = DBPEDIA_PATH, query = list(text = raw_text, confidence = confidence_lvl))
  data = fromJSON(rawToChar(request$content))
  types <- data$Resources$"@types"
  # get only the dbpedia data
  #types <- regmatches(types, gregexpr("DBpedia:[a-zA-Z]*", types))
  types <- regmatches(types, gregexpr("(?<=DBpedia:)[a-zA-Z]*", types, perl = TRUE))
  return(paste(unlist(types), collapse = ' '))
}

annotate_row <- function(x, confidence_lvl){
  x[2] <- paste(x[2], get_types_from_text(x[2],confidence_lvl), sep = " ")
  return(x)
}

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

t <- get_types_from_text(test_text, 0.3)
#request$status_code
#response <- content(request, as = "text", encoding = "UTF-8")
