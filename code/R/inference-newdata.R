#####################
# Config parameters #
#####################
# en or es
lang <- "en"
print(paste("Using language:",lang,", please check the paths and services are according to the lang selected"))

# Ontology trees
#ont_path <- "datasets/dbpedia_2016-10.owl"
path_printable_names <- paste("datasets/", lang,"/printable_names_",lang,".csv",sep = "")

# Name entity
use_ne <- TRUE
use_only_ne <- FALSE  
confidence_lvl <- 0.33
service_url <- DBPEDIA_PATH <- "https://api.dbpedia-spotlight.org/en/annotate"
path_dict_ne <- paste("datasets/", lang,"/types_dict_",lang,".csv",sep = "")
dbo_only <- TRUE
use_ne_path2root <- FALSE
use_printable_names <- FALSE

# text preprocessing and vectorization
use_preprocessing <- FALSE
use_stw <-TRUE
custom_stw <- c("@en", "\"@en", "@es", "\"@es")
use_stem <- TRUE
use_lemm <- FALSE  
remove_punctuation <- FALSE # Check if original does it

use_tfidf <- FALSE  # TFIDF IS A NO SENSE WITH 1 DOCUMENT. 
#Either we recover the frequency of the previous features and the unweighted matrix to re-weight every run or we just use TF

# Unseen pred
model_path <- paste("models/",lang,"/model10k.rds",sep = "")
test_text <- "Animalia is an illustrated children's book by Graeme Base. It was originally published in 1986, followed by a tenth anniversary edition in 1996, and a 25th anniversary edition in 2012. Over three million copies have been sold. A special numbered and signed anniversary edition was also published in 1996, with an embossed gold jacket."


library(quanteda)
library(udpipe)
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
  ne_types <- unlist(ne_types)
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
  txt_tokens <- tokens_tolower(x = txt_tokens)
  if(stw_opt){
    txt_tokens <- tokens_select(x = txt_tokens, pattern = c(stopwords(language), custom_sw), selection = "remove")
  }
  if(lemm_opt){
    lemm_tokens <- udpipe(x=as.list(txt_tokens), language)
    txt_tokens <- tokens_replace(txt_tokens, lemm_tokens$token, lemm_tokens$lemma)
  }
  if(stem_opt){
    txt_tokens <- tokens_wordstem(x = txt_tokens, language = language)
  }
  result_text = paste(unlist(txt_tokens),collapse = ' ')
  return(result_text)
}

vectorizate_unseen_text <- function(unseen_text, tfidf=TRUE){
  unseen_text = as.character(unseen_text)
  my_corpus <- tokens(unseen_text)
  tdm <- dfm(my_corpus, tolower=FALSE)
  if(tfidf){
    tdm <- dfm_tfidf(tdm)
  }
  return(tdm)
}

load_model <- function(model_path){
  model <- readRDS(model_path)
  model$x <- NULL
  return(model)
}

predict_svm <- function(object, newdata = NULL, type = c("class", "probability"), force = TRUE) {
  
  type <- match.arg(type)
  
  if (!is.null(newdata)) {
    data <- as.dfm(newdata)
  } else {
    data <- as.dfm(object$x)
  }
  
  # the seq_along is because this will have an added term "bias" at end if bias > 0
  model_featnames <- colnames(object$weights)
  if (object$bias > 0) model_featnames <- model_featnames[-length(model_featnames)]
  
  data <- if (is.null(newdata))
    suppressWarnings(quanteda.textmodels:::force_conformance(data, model_featnames, force))
  else
    quanteda.textmodels:::force_conformance(data, model_featnames, force)
  if (type == "class") {
    pred_y <- predict(object$svmlinfitted, newx = as(data, "RsparseMatrix"), proba = FALSE)
    pred_y <- pred_y$predictions
    names(pred_y) <- docnames(data)
  } else if (type == "probability") {
    if (object$type != 0)
      stop("probability predictions not implemented for this model type")
    pred_y <- predict(object$svmlinfitted, newx = as(data, "RsparseMatrix"), proba = TRUE)
    pred_y <- pred_y$probabilities
    rownames(pred_y) <- docnames(data)
  }
  
  return(pred_y)
}

main_pipeline <- function(unseen_text, model){
  
  if(use_ne){
    ne_types <- get_annotations_unseen_text(unseen_text, confidence_lvl = 0.33, dbo_only=dbo_only, use_ne_path2root = use_ne_path2root,
                                            dbo_tree=NULL, path_types_dic=NULL, printable_names=FALSE, printable_names_df = NULL)
    unseen_text <- paste(unseen_text, paste(unlist(ne_types),collapse = ' '),collapse = ' ')
  }
  
  if(use_preprocessing){
    unseen_text <- preprocess_unseen_text(unseen_text, stw_opt = use_stw, punct_remove = remove_punctuation, stem_opt = use_stem, 
                                          lemm_opt = use_lemm, custom_sw = custom_stw, language = lang)
  }
  unseen_tdm <- vectorizate_unseen_text(unseen_text, tfidf = use_tfidf)
  unseen_tdm <- dfm_replace(unseen_tdm, pattern = "Bias", replacement = "bias")
  unseen_tdm <- dfm_match(unseen_tdm, colnames(model$weights))
  
  # evaluate
  #predicted <- predict_svm(model, newdata = unseen_tdm, type = "class")
  return(unseen_tdm)
}
#model = load_model(model_path)
test_texts = c(
  "Barack Hussein Obama II is an American politician who is the 44th and current President of the United States. He is the first African American to hold the office and the first president born outside the continental United States. Born in Honolulu, Hawaii, Obama is a graduate of Columbia University and Harvard Law School, where he was president of the Harvard Law Review. He was a community organizer in Chicago before earning his law degree. He worked as a civil rights attorney and taught constitutional law at the University of Chicago Law School between 1992 and 2004. While serving three terms representing the 13th District in the Illinois Senate from 1997 to 2004, he ran unsuccessfully in the Democratic primary for the United States Hou",
  "Elon Reeve Musk (/ˈiːlɒn ˈmʌsk/; born June 28, 1971) is a South African-born Canadian-American business magnate, investor, engineer and inventor. He is the founder, CEO, and CTO of SpaceX; co-founder, CEO, and product architect of Tesla Motors; co-founder and chairman of SolarCity; co-chairman of OpenAI; co-founder of Zip2; and founder of X.com which merged with PayPal of Confinity. As of June 2016, he has an estimated net worth of US$12.7 billion, making him the 83rd wealthiest person in the world. Musk has stated that the goals of SolarCity, Tesla Motors, and SpaceX revolve around his vision to change the world and humanity. His goals include reducing global warming through sustainable energy production and consumption, and reducing the \"risk of human extinction\" by \"making life multiplanetary\" by setting up a human colony on Mars. In addition to his primary business pursuits, he has also envisioned a high-speed transportation system known as the Hyperloop, and has proposed a VTOL supersonic jet aircraft with electric fan propulsion, known as the Musk electric jet.",
  "Anton Drexler (13 June 1884 – 24 February 1942) was a German far-right political leader of the 1920s who was instrumental in the formation of the pan-German and anti-Semitic German Workers' Party (Deutsche Arbeiterpartei – DAP), the antecedent of the Nazi Party (Nationalsozialistische Deutsche Arbeiterpartei – NSDAP). Drexler served as mentor to Adolf Hitler during his early days in politics.",
  test_text
)
unseen_text = test_texts[4]
unseen_tdm = main_pipeline(unseen_text, model)
predicted <- predict_svm(model, newdata = unseen_tdm, type = "class")
print(predicted)
#print(model$classnames[unlist(predicted)])
