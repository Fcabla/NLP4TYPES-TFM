library("quanteda")
library("quanteda.textmodels")
library("quanteda.classifiers")
library("groupdata2")
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
build_train_model <- function(train_data, labels){
  # Building the model
  tmod <- textmodel_svm(train_data, y = labels, weight = "uniform", verbose=TRUE)
  #, type=2
  return(tmod)
}

# Function to predict the test/validation dataset
predict_abstracts <- function(model, test){
  # Predict https://www.rdocumentation.org/packages/quanteda.textmodels/versions/0.9.3/topics/predict.textmodel_svm
  predicted <- predict(model, newdata = test, type = "class")
  return(predicted)
}

#https://rdrr.io/github/quanteda/quanteda.classifiers/src/R/crossval.R
# https://rdrr.io/github/quanteda/quanteda.classifiers/man/crossval.html
#crossval(tmod, k = k_crossval, by_class = FALSE, verbose = TRUE)
assess_model_cv <- function(x, k = 5, by_class = FALSE, verbose = FALSE, ont_tree){
  # create folds vector - many ways to do this, I chose something available
  folds <- fold(data.frame(doc_id = docnames(x)), k = k)[[".folds"]]

  results <- data.frame(acc=double(k), hprec=double(k), hrec=double(k), hF=double(k), stringsAsFactors = F)
  
  # loop across folds and refit model, add to results list
  for (i in seq_len(k)) {
    
    this_mod <- do.call(class(x)[1],
                        args = list(x = dfm_subset(x$x, folds != i),
                                    y = x$y[folds != i]))
    this_pred <- predict(this_mod, newdata = dfm_subset(x$x, folds == i),
                         type = "class")
    
    metrics <- evaluate_results(this_pred, dfm_subset(x$x, folds == i), ont_tree)
    results[i, ] <- metrics
  }
  
  summ <- sapply(results, mean)
  
  # this may not be the "correct" way to do it - here it averages across
  # class-specific averages.  Should we average across classes first within
  # folds and then average across folds?
  if (!by_class)
    summ <- apply(summ, 2, mean)
  
  if (verbose) {
    cat("Cross-validation:\n\nMean results for k =", k, "folds:\n\n")
    print(summ)
    invisible(summ)
  } else {
    #summ
  }
  return(summ)
}


#https://rdrr.io/github/quanteda/quanteda.classifiers/src/R/crossval.R
# https://rdrr.io/github/quanteda/quanteda.classifiers/man/crossval.html
#crossval(tmod, k = k_crossval, by_class = FALSE, verbose = TRUE)
assess_model_cv_tdm <- function(train_data, k = 5, by_class = FALSE, verbose = FALSE, ont_tree){
  # create folds vector - many ways to do this, I chose something available
  folds <- fold(data.frame(doc_id = docnames(train_data)), k = k)[[".folds"]]
  
  results <- data.frame(acc=double(k), hprec=double(k), hrec=double(k), hF=double(k), stringsAsFactors = F)
  
  # loop across folds and refit model, add to results list
  for (i in seq_len(k)) {
    tr <- dfm_subset(train_data, folds != i)
    this_mod <- textmodel_svm(tr, y = tr$type, weight = "uniform")
    
    te <- dfm_subset(train_data, folds == i)
    this_pred <- predict(this_mod, newdata = te, type = "class")
    
    metrics <- evaluate_results(this_pred, te, ont_tree)
    results[i, ] <- metrics
  }
  
  summ <- sapply(results, mean)
  
  # this may not be the "correct" way to do it - here it averages across
  # class-specific averages.  Should we average across classes first within
  # folds and then average across folds?
  if (!by_class)
    #summ <- apply(summ, 2, mean)
  
  if (verbose) {
    cat("Cross-validation:\n\nMean results for k =", k, "folds:\n\n")
    print(summ)
    invisible(summ)
  } else {
    #summ
  }
  return(summ)
}
