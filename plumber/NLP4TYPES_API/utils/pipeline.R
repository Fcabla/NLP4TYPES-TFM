library(quanteda)
#library(udpipe)
library(lexicon)
library(text2vec)
library(httr)
library(jsonlite)
library(data.table)
library(LiblineaR)
library("quanteda.textmodels")

get_types_from_text <- function(unseen_text, confidence_lvl, retry_num = 0){
  request <- GET(url = DBPEDIA_PATH, query = list(text = unseen_text, confidence = confidence_lvl))
  if(status_code(request) == 200){
    data = fromJSON(rawToChar(request$content))
    resources_types <- data$Resources$"@types"
    # Remove no types
    resources_types <- resources_types[resources_types != ""]
    all_types <- paste(unlist(resources_types), collapse = ' ')
    all_types <- strsplit(all_types, ",")
    return(all_types)
  }else{
    # 414 --> query too long | 400
    #print(status_code(request))
    return("")
    #retry_num <- retry_num + 1
    #print(paste("failed to name entity raw text, retry number", retry_num, collapse = ' '))
    #Sys.sleep(0.2*retry_num)
    return(get_types_from_text(unseen_text, confidence_lvl, retry_num))
  }
}

get_annotations_unseen_text <- function(unseen_text, confidence_lvl = 0.33, dbo_only=TRUE, use_ne_path2root = FALSE, dbo_tree=NULL, 
                                 path_types_dic=NULL, printable_names=FALSE, printable_names_df = NULL){
  
  ne_types <- get_types_from_text(unseen_text = unseen_text, confidence_lvl = confidence_lvl)
  
  if(dbo_only){
    ne_types <- regmatches(ne_types, gregexpr("(?<=DBpedia:)[a-zA-Z]*", ne_types, perl = TRUE))
  }else{
    ne_types <- regmatches(ne_types, gregexpr("(?<=:)[a-zA-Z0-9]*", ne_types, perl = TRUE))
  }
  
  if(use_ne_path2root){
    print("not implemented in this version")
  }
  
  if(printable_names){
    print("not implemented in this version")
  }
  
  return(ne_types)
}

preprocess_unseen_text <- function(unseen_text, stw_opt = TRUE, punct_remove = TRUE, stem_opt = TRUE, 
                                   lemm_opt = FALSE, custom_sw = "", language = "english"){
  unseen_text = as.character(unseen_text)
  #my_corpus <- corpus(unseen_text)
  txt_tokens <- tokens(x = unseen_text, remove_punct = punct_remove)
  use_low = FALSE
  if(use_low){
    print('Lowercasing abstracts')
    txt_tokens <- tokens_tolower(x = txt_tokens)
  }
  if(stw_opt){
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords(language), custom_sw), selection = "remove")
  }
  if(lemm_opt){
    #lemm_tokens <- udpipe(x=as.list(txt_tokens), language)
    #txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
    txt_tokens <- tokens_replace(txt_tokens, pattern = lexicon::hash_lemmas$token, replacement = lexicon::hash_lemmas$lemma)
  }
  if(stem_opt){
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = language)
  }
  result_text = paste(unlist(txt_tokens),collapse = ' ')
  return(result_text)
}

vectorizate_unseen_text_count <- function(unseen_text){
  unseen_text = as.character(unseen_text)
  my_corpus <- tokens(unseen_text)
  tdm <- dfm(my_corpus, tolower=FALSE)

  return(tdm)
}

vectorizate_unseen_text <- function(unseen_text, x, tfidf=TRUE){
  unseen_text = as.character(unseen_text)
  my_corpus <- tokens(unseen_text)
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

load_model <- function(model_path){
  model <- readRDS(model_path)
  #model$x <- NULL
  return(model)
}

main_pipeline <- function(unseen_text, model, lang){
  
  if(use_ne){
    ne_types <- get_annotations_unseen_text(unseen_text, confidence_lvl = 0.33, dbo_only=dbo_only, use_ne_path2root = use_ne_path2root,
                                            dbo_tree=NULL, path_types_dic=NULL, printable_names=FALSE, printable_names_df = NULL)
    unseen_text <- paste(unseen_text, paste(unlist(ne_types),collapse = ' '),collapse = ' ')
  }
  
  if(use_preprocessing){
    unseen_text <- preprocess_unseen_text(unseen_text, stw_opt = use_stw, punct_remove = remove_punctuation, stem_opt = use_stem, 
                                       lemm_opt = use_lemm, custom_sw = custom_stw, language = lang)
  }
  #unseen_tdm <- vectorizate_unseen_text(unseen_text, tfidf = use_tfidf)
  #if(use_tfidf)
  unseen_tdm <- vectorizate_unseen_text(unseen_text, model$x, tfidf = use_tfidf)
  unseen_tdm <- dfm_replace(unseen_tdm, pattern = "Bias", replacement = "bias")
  #unseen_tdm <- dfm_match(unseen_tdm, colnames(model$weights))
  # evaluate
  predicted <- predict(model, newdata = unseen_tdm, type = "class")
  gc()
  return(as.character(predicted))
}



