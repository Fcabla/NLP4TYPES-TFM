library(quanteda)
library(udpipe)
library(text2vec)
#https://quanteda.io/reference/convert.html

preprocess_dataframe_abstracts <- function(df, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, custom_sw = "", language = "english"){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  txt_tokens <- tokens(x = my_corpus, remove_punct = punct_remove, include_docvars = TRUE)
  txt_tokens <- tokens_tolower(x = txt_tokens)
  
  if(stw_opt){
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords(language), custom_sw), selection = "remove")
  }
  
  if(lemm_opt){
    # https://www.r-bloggers.com/2018/09/udpipe-version-0-7-for-natural-language-processing-nlp-alongside-tidytext-quanteda-tm/
    lemm_tokens <- udpipe(x=as.list(txt_tokens), language)
    txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
  }
  
  if(stem_opt){
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = language)
  }
  
  #if(printable_names){}
  f <- function(x){
    paste(unlist(x), collapse = ' ')
  }
  
  df$abstract <- sapply(txt_tokens, f)
  return(df)
}

vectorizate_dataframe <- function(df, tfidf=TRUE){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  tdm <- dfm(my_corpus, tolower=FALSE)
  #tdm <- dfm_trim(tdm, sparsity = 0.96, verbose = TRUE)
  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
    
  return(tdm)
  
  #tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, max_features = 0,ngram_range = c(1, 1), regex = , remove_stopwords = , split = ,lowercase = 
  #                            ,smooth_idf = ,norm = )
  tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, ngram_range = c(1, 1), split =" " ,lowercase = T, smooth_idf = T, norm = T)
  tf$fit_transform(abstracts_list)
}

# Function to process a dataframe applying classical text preprocessing techniques
# Transform the preprocessed text in to a term document matrix and returns it
process_dataframe <- function(df, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, tfidf = TRUE, custom_sw = ""){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  
  tdm <- vectorizate_corpus(my_corpus, stw_opt, punct_remove, stem_opt, lemm_opt, tfidf, custom_sw)
  return(tdm)
}

vectorizate_corpus <- function(crps, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, tfidf = TRUE, custom_sw = "", language = "english"){
  
  txt_tokens <- tokens(x = crps, remove_punct = punct_remove, include_docvars = TRUE)
  # Test if to lower affects performance!
  txt_tokens <- tokens_tolower(x = txt_tokens)
  if(stw_opt)
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords(language), custom_sw), selection = "remove")
  
  if(lemm_opt){
    # https://www.r-bloggers.com/2018/09/udpipe-version-0-7-for-natural-language-processing-nlp-alongside-tidytext-quanteda-tm/
    lemm_tokens <- udpipe(x=as.list(txt_tokens), language)
    txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
  }
  
  if(stem_opt)
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = language)
  
  tdm <- dfm(txt_tokens, tolower=FALSE, remove_punct = punct_remove)
  tdm <- dfm_trim(tdm, sparsity = 0.96, verbose = TRUE)
  if(tfidf)
    tdm <- dfm_tfidf(tdm)
  return(tdm)
}

# NOT USED
vectorizate_dataframe_t2v <- function(df){
  # http://text2vec.org/vectorization.html
  it_train = itoken(df$abstract, 
                    preprocessor = tolower, 
                    tokenizer = word_tokenizer, 
                    ids = df$individual, 
                    progressbar = T)
  vocab = create_vocabulary(it_train)
  
  vectorizer = vocab_vectorizer(vocab)
  dtm_train = create_dtm(it_train, vectorizer)
  
  #dtm_train_l2_norm = normalize(dtm_train, "l2")
  
  # define tfidf model
  tfidf = TfIdf$new(smooth_idf = T, norm = "l2")
  # fit model to train data and transform train data with fitted model
  dtm_train_tfidf = fit_transform(dtm_train, tfidf)
  # tfidf modified by fit_transform() call!
  # apply pre-trained tf-idf transformation to test data
  #dtm_test_tfidf = create_dtm(it_test, vectorizer)
  #dtm_test_tfidf = transform(dtm_test_tfidf, tfidf)
  
  return(dtm_train_tfidf)
  #tf = TfIdfVectorizer$new(min_df = 1,max_df = 1.0,ngram_range = c(1, 1),split = " ",lowercase = T,smooth_idf = T,norm = T)
  #tf$fit_transform(abstracts_list)
}