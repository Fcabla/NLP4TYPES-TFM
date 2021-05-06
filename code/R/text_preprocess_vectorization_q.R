library(quanteda)
library(udpipe)
#https://quanteda.io/reference/convert.html


# Function to process a dataframe applying classical text preprocessing techniques
# Transform the preprocessed text in to a term document matrix and returns it
process_dataframe <- function(df, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, tfidf = TRUE, custom_sw = ""){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  tdm <- vectorizate_corpus(my_corpus, stw_opt, punct_remove, stem_opt, lemm_opt, tfidf, custom_sw)
  return(tdm)
}

# ToDo: preprocess unseen data (Inference end user).
process_text <- function(raw_text, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, tfidf = TRUE, custom_sw = ""){
  my_corpus <- corpus(raw_text)
  tdm <- vectorizate_corpus(my_corpus, stw_opt, punct_remove, stem_opt, lemm_opt, tfidf, custom_sw)
  return(tdm)
}


vectorizate_corpus <- function(crps, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, tfidf = TRUE, custom_sw = ""){
  
  txt_tokens <- tokens(x = crps, remove_punct = punct_remove, include_docvars = TRUE)
  # Test if to lower affects performance!
  # txt_tokens <- tokens_tolower(x = txt_tokens)
  if(stw_opt)
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords("english"), custom_sw), selection = "remove")
  
  if(lemm_opt){
    # https://www.r-bloggers.com/2018/09/udpipe-version-0-7-for-natural-language-processing-nlp-alongside-tidytext-quanteda-tm/
    lemm_tokens <- udpipe(x=as.list(txt_tokens), "english")
    txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
  }
  
  if(stem_opt)
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = "english")
  
  tdm <- dfm(txt_tokens, tolower=TRUE, stem=stem_opt, remove_punct = punct_remove)
  if(tfidf)
    tdm <- dfm_tfidf(tdm)
  return(tdm)
}