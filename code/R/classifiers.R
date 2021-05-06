library("quanteda")
library("quanteda.textmodels")
library("quanteda.classifiers")

#https://rdrr.io/cran/quanteda.textmodels/man/textmodel_svm.html

# Function to split the current dataframe in to training and test
split_data_trte <- function(tdm, trte_split = 0.75){
  # Train/test or train for crossval and test for validation
  # Splitting the dataset
  set.seed(7)
  tdm_len <- dim(tdm)[1]
  indexes <- 1:tdm_len
  n_tr_instances <- round(trte_split*tdm_len)
  train_indexes <- sample(indexes, n_tr_instances, replace = FALSE)
  test_indexes <- indexes[!indexes %in% train_indexes]
  tr_tdm <- tdm[train_indexes,]
  te_tdm <- tdm[test_indexes, ]
  dtms <- list(tr_tdm, te_tdm)
  return(dtms)
}

# Build the svm model with quanteda
build_train_model <- function(train, crossvalidation=TRUE, k_crossval=5){
  # Building the model
  tmod <- textmodel_svm(train, y = train$type)
  if(crossvalidation){
    # https://rdrr.io/github/quanteda/quanteda.classifiers/man/crossval.html
    crossval(tmod, k = k_crossval, by_class = FALSE, verbose = FALSE)
  }
  return(tmod)
}

# Function to predict the test/validation dataset
predict_abstracts <- function(model, test){
  # Predict https://www.rdocumentation.org/packages/quanteda.textmodels/versions/0.9.3/topics/predict.textmodel_svm
  predicted <- predict(model, newdata = test, type = "class")
  return(predicted)
}

