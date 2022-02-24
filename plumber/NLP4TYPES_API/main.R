library("plumber")
# load config parametters
source("utils/config.R")
# load the helper methods and functions
source("utils/pipeline.R")
model_en <- load_model(model_path_en)
model_es <- load_model(model_path_es)

#* @apiTitle NLP4TYPES-TFM
#* @apiDescription This application classifies an input text in to one of the classes from the DBpedia ontology. The input text should describe any kind of entity (e.g. Person, Place, Artist, etc.) with a length between 5 and 50000 characters. This work is part of a final master work of the <a href='http://dia.fi.upm.es/mastercd'>MSC in data science</a> of the Universidad Politecnica de Madrid.
  
#* Uses the model to predict the input text (description)
#* @param unseen_text Description text to classify
#* @get /predict_en
function(unseen_text="") {
  main_pipeline(unseen_text, model_en, "english")
}

#* Uses the model to predict the input text (description)
#* @param unseen_text Description text to classify
#* @get /predict_es
function(unseen_text="") {
  main_pipeline(unseen_text, model_es, "spanish")
}

# Uses the model to predict the input text (description)
# @param unseen_text Text to predict its type
# @post /predict
#function(unseen_text="") {
#  main_pipeline(unseen_text, model)
#}

# r <- plumb("main.R")
# r$run(port = 8000)


