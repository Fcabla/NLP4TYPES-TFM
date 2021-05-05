library(quanteda)
#https://quanteda.io/reference/convert.html


# Function to process a dataframe applying classical text preprocessing techniques
# Transform the preprocessed text in to a term document matrix and returns it
process_dataframe <- function(df, stem_opt=TRUE, punct_remove=TRUE, tfidf=TRUE, custom_sw){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  tdm <- vectorizate_corpus(my_corpus, stem_opt, punct_remove, tfidf, custom_sw)
  return(tdm)
}

# ToDo: preprocess unseen data (Inference end user).
process_text <- function(raw_text, stem_opt=TRUE, punct_remove=TRUE, tfidf=TRUE, custom_sw){
  my_corpus <- corpus(raw_text)
  tdm <- vectorizate_corpus(my_corpus, stem_opt, punct_remove, tfidf, custom_sw)
  return(tdm)
}


vectorizate_corpus <- function(crps, stem_opt=TRUE, punct_remove=TRUE, tfidf=TRUE, custom_sw){
  tdm <- dfm(crps, tolower=TRUE, stem=stem_opt, remove_punct = punct_remove, remove=c(stopwords("english"), custom_sw))
  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
}