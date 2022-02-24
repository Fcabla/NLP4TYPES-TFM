library(quanteda)
library(udpipe)
library(lexicon)
#library(textstem)
#https://quanteda.io/reference/convert.html
#python version of idf:
# https://github.com/scikit-learn/scikit-learn/blob/844b4be24/sklearn/feature_extraction/text.py#L1700

preprocess_dataframe_abstracts <- function(df, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, lemm_opt = FALSE, custom_sw = "", language = "english", use_low=TRUE){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  txt_tokens <- quanteda::tokens(x = my_corpus, remove_punct = punct_remove, include_docvars = TRUE)
  
  if(use_low){
    print('    Lowercasing abstracts')
    txt_tokens <- tokens_tolower(x = txt_tokens)
  }
  
  if(stw_opt){
    print('    Removing Stopwords')
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords(language), custom_sw), selection = "remove")
  }
  
  if(lemm_opt){
    print('    Applying lematization')
    # https://www.r-bloggers.com/2018/09/udpipe-version-0-7-for-natural-language-processing-nlp-alongside-tidytext-quanteda-tm/
    #lemm_tokens <- udpipe(x=as.list(txt_tokens), language)
    #txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
    #txt_tokens <- lemmatize_words(txt_tokens)
    txt_tokens <- tokens_replace(txt_tokens, pattern = lexicon::hash_lemmas$token, replacement = lexicon::hash_lemmas$lemma)
  }
  
  if(stem_opt){
    print('    Applying stemming')
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = language)
  }
  
  #if(printable_names){}
  f <- function(x){
    paste(unlist(x), collapse = ' ')
  }
  print('    rebuilding abstracts¨')
  df$abstract <- sapply(txt_tokens, f)
  return(df)
}

vectorizate_dataframe <- function(df, tfidf=TRUE, trim_tdm, min_term, min_doc){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  tdm <- dfm(my_corpus, tolower=FALSE)
  if(trim_tdm){
    #tdm <- dfm_trim(tdm, sparsity = 0.96, verbose = TRUE)
    print(paste("trimming the tdm with min_term", min_term, " and min_doc", min_doc, sep = " "))
    print(dim(tdm))
    tdm <- dfm_trim(tdm, min_termfreq = min_term, min_docfreq = min_doc, termfreq_type = "quantile")
    print(dim(tdm))
  }

  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
    
  return(tdm)
  
  #tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, max_features = 0,ngram_range = c(1, 1), regex = , remove_stopwords = , split = ,lowercase = 
  #                            ,smooth_idf = ,norm = )
  #tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, ngram_range = c(1, 1), split =" " ,lowercase = T, smooth_idf = T, norm = T)
  #tf$fit_transform(abstracts_list)
}

vectorizate_dataframe_ngrams <- function(df, tfidf=TRUE, ngrams=2, trim_tdm, min_term, min_doc){
  df$abstract <- as.character(df$abstract)
  my_corpus <- corpus(df, text_field = "abstract", docid_field = "individual")
  my_corpus <- tokens(my_corpus)
  my_corpus <- tokens_ngrams(my_corpus, n=ngrams)
  tdm <- dfm(my_corpus, tolower=FALSE)
  
  if(trim_tdm){
    #tdm <- dfm_trim(tdm, sparsity = 0.96, verbose = TRUE)
    print(paste("trimming the tdm with min_term", min_term, " and min_doc", min_doc, sep = " "))
    print(tdm)
    tdm <- dfm_trim(tdm, min_termfreq = min_term, min_docfreq = min_doc)
    print(tdm)
  }
  
  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
  
  return(tdm)
  
  #tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, max_features = 0,ngram_range = c(1, 1), regex = , remove_stopwords = , split = ,lowercase = 
  #                            ,smooth_idf = ,norm = )
  #tf <- TfIdfVectorizer$new(min_df= 1, max_df = 1, ngram_range = c(1, 1), split =" " ,lowercase = T, smooth_idf = T, norm = T)
  #tf$fit_transform(abstracts_list)
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

vectorizate_new_unseen_data <- function(x, new_df){
  #gold standard df to dfm
  new_df$abstract <- as.character(new_df$abstract)
  my_corpus <- corpus(new_df, text_field = "abstract", docid_field = "individual")
  my_corpus <- tokens(my_corpus)
  # tf part
  tdm <- dfm(my_corpus, tolower=FALSE)
  tdm <- dfm_weight(tdm, scheme = "count")
  # match feature names with the model before weighting!
  tdm <- dfm_match(tdm, featnames(x))
  
  # idf part
  document_frequency = docfreq(x, scheme = "inverse")
  #there are features in x (models tdm) that have 0 doc freq, prob bcause they appeare few times ??
  # https://github.com/quanteda/quanteda/blob/master/R/dfm_weight.R
  # https://quanteda.io/reference/dfm_tfidf.html
  document_frequency[document_frequency == Inf] = 0
  j <- as(tdm, "dgTMatrix")@j + 1L
  tdm@x <- tdm@x * document_frequency[j]
  attrs <- attributes(tdm)
  tdm <- quanteda:::rebuild_dfm(tdm, attrs)
  return(tdm)
}