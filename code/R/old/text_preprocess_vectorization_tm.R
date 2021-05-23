# UTILIZAR QUANTEDA!!!! 
# Transformar 
library(tm)
library(textstem)

process_corpus <- function(corpus){
  
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus,removeWords, c(stopwords("english"),"@en")) 
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, lemmatize_strings)
  corpus <- tm_map(corpus, stripWhitespace)
  return (corpus)
}

process_dataframe <- function(df){
  names(df)[1] <- "doc_id"
  names(df)[2] <- "text"
  corpus <- Corpus(DataframeSource(df))
  print("got corpus")
  corpus <- process_corpus(corpus)

  return (corpus)
}

process_text <- function(){
  
}

vectorize_corpus <- function(corpus){
  tfidf = TermDocumentMatrix(corpus, control = list(weighting = weightTfIdf))
  return(tfidf)
}

