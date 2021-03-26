library(e1071) 
library(quanteda.textmodels)
library(RTextTools)
#https://rdrr.io/cran/quanteda.textmodels/man/textmodel_svm.html


svm_e1071 <- function(tdm, df){
  df_tdm <- convert(tdm, to="data.frame")
  df_tdm <- subset(df_tdm, select = -type )
  df_o <- subset(df, select = -abstract )
  names(df_o)[1] <- "doc_id"
  df_tdm <- merge(df_tdm, df_o, by="doc_id")
  n <- nrow(df_tdm)  # Number of observations
  ntrain <- round(n*0.75)  # 75% for training set
  tindex <- sample(n, ntrain)   # Create a random index
  set.seed(7)    # Set seed for reproducible results> tindex <- sample(n, ntrain)   # Create a random index
  
  train_set <- df_tdm[tindex,]   # Create training set
  test_set <- df_tdm[-tindex,]   # Create test set> svm1 <- svm(Species~., data=train_iris, 
  
  svm1 <- svm(type~., data=train_set, 
              method="C-classification", kernal="radial", 
              gamma=0.1, cost=10)
  
  print (summary(svm1))
  
  prediction <- predict(svm1, test_set)
}
svm_e1071(tdm,df)

svm_quanteda <- function(){
  #quanteda
  tmod <- textmodel_svm(tdm, y = tdm$type)
  predict(tmod)
}

svm_rtexttolls <- function(){
  #rtextools
  container <- create_container(convert(tdm, to = "matrix"), tdm$type, trainSize = 1:200, testSize = 201:304, virgin = FALSE)
  model_SVM <- train_model(container,"SVM")
  SVM_CLASSIFY <- classify_model(container, model_SVM)
  analytics <- create_analytics(container, cbind(SVM_CLASSIFY))
}


