library(quanteda)
#https://quanteda.io/reference/convert.html

# Function to process a dataframe applying classical text preprocessing techniques
# Transform the preprocessed text in to a term document matrix and returns it
process_dataframe <- function(df, stem_opt=TRUE, punct_remove=TRUE, tfidf=TRUE, custom_sw){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  print(my_corpus)
  tdm <- dfm(my_corpus, tolower=TRUE, stem=stem_opt, remove_punct = punct_remove, remove=c(stopwords("english"), custom_sw))
  
  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
  return(tdm)
}

# ToDo: preprocess unseen data.
process_text <- function(){
  
}
