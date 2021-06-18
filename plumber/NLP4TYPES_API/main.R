library("plumber")
# load config parametters
source("utils/config.R")
# load the helper methods and functions
source("utils/pipeline.R")

model_en <- load_model(model_path_en)
model_es <- load_model(model_path_es)

#* Uses the model to predict the input text (description)
#* @param unseen_text Text to predict its type
#* @get /predict_en
function(unseen_text="") {
  main_pipeline(unseen_text, model_en, "english")
}

#* Uses the model to predict the input text (description)
#* @param unseen_text Text to predict its type
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


