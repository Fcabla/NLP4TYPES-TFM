library("quanteda")
library("quanteda.textmodels")
library("quanteda.classifiers")
library("groupdata2")
#https://rdrr.io/cran/quanteda.textmodels/man/textmodel_svm.html
# https://github.com/quanteda/quanteda/issues/46

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
  library(LiblineaR)
  predicted <- predict(model, newdata = test, type = "class")
  return(predicted)
}

#https://rdrr.io/github/quanteda/quanteda.classifiers/src/R/crossval.R
# https://rdrr.io/github/quanteda/quanteda.classifiers/man/crossval.html
#crossval(tmod, k = k_crossval, by_class = FALSE, verbose = TRUE)
assess_model_cv_tdm <- function(train_data, k = 5, by_class = FALSE, verbose = FALSE, ont_tree = NULL, dict_paths = NULL){
  
  if(is.null(ont_tree) & is.null(path_types_dic)){
    print("ERROR")
    return()
  }
  # create folds vector - many ways to do this, I chose something available
  folds <- fold(data.frame(doc_id = docnames(train_data)), k = k)[[".folds"]]
  
  results <- data.frame(acc=double(k), hprec=double(k), hrec=double(k), hF=double(k), stringsAsFactors = F)
  
  # loop across folds and refit model, add to results list
  for (i in seq_len(k)) {
    tr <- dfm_subset(train_data, folds != i)
    #this_mod <- textmodel_svm(tr, y = tr$type, weight = "uniform")
    this_mod<- fit_linear_svc(x=tr, y=tr$type, weight="uniform")
    
    te <- dfm_subset(train_data, folds == i)

    this_pred <- predict(this_mod, newdata = te, type = "class")
    if(!is.null(ont_tree)){
      metrics <- evaluate_results(this_pred, te$type, ont_tree)
    }else{
      metrics <- evaluate_results_dict(this_pred, te$type, path_types_dic)
    }
    
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

fit_linear_svc <- function(x, y, weight = c("uniform", "docfreq", "termfreq"), type = 1, verbose=FALSE){
  
  x <- as.dfm(x)
  if (!sum(x)) stop(message_error("dfm_empty"))
  call <- match.call()
  weight <- match.arg(weight)
  x_train <- x
  y_train <- y
  # exclude NA in training labels
  #x_train <- suppressWarnings(
  #  dfm_trim(x[!is.na(y), ], min_termfreq = .0000000001, termfreq_type = "prop")
  #)
  #y_train <- y[!is.na(y)]
  
  # remove zero-variance features
  #constant_features <- which(apply(x_train, 2, stats::var) == 0)
  #if (length(constant_features)) x_train <- x_train[, -constant_features]
  
  # set wi depending on weight value
  if (weight == "uniform") {
    wi <- NULL
  } else if (weight == "docfreq") {
    wi <- prop.table(table(y_train))
  } else if (weight == "termfreq") {
    wi <- rowSums(dfm_group(x_train, y_train))
    wi <- wi / sum(wi)
  }
  gc()
  x_temp <- as(x_train, "RsparseMatrix")
  svmlinfitted <- LiblineaR::LiblineaR(x_temp, target = y_train, wi = wi, type = type, verbose = verbose)
  rm(x_temp)
  gc()
  colnames(svmlinfitted$W)[seq_along(featnames(x_train))] <- featnames(x_train)
  result <- list(
    x = x, y = y,
    weights = svmlinfitted$W,
    algorithm = svmlinfitted$TypeDetail,
    type = svmlinfitted$Type,
    classnames = svmlinfitted$ClassNames,
    bias = svmlinfitted$Bias,
    svmlinfitted = svmlinfitted,
    call = call
  )
  class(result) <- c("textmodel_svm", "textmodel", "list")
  return(result)
}