library(quanteda.textmodels)

# http://mappings.dbpedia.org/server/ontology/classes/
# http://mappings.dbpedia.org/server/ontology/

# ToDo:
# 1.  Get dbpedia ontology tree --> ontology classes and subclasses
# 2.  Get predictions and ground truth aka labels
# 3.  For each prediction and label do:
# 4.    Check if prediction and label are the same (accuracy)
# 5.    Get ontology path of the prediction
# 6.    Get ontology path of the label
# 7.    Intersect both paths and count how many are in both (hP and hR)
# 8.    Accumulate step 7, length of the prediction path and length of the label path
# 9.  End For
# 10. Calculate hP, hR, hF and regular accuracy with the accumulated variables (step 8)

# ac <- (TP+FP)/(TP+TN+FP+FN)
# hP <- length(hP == hR) / total length of predictions
# hR <- length(hP == hR) / total length of labels
# hF <- (2*hP*hR)/(hP+hR)

evaluate_results <- function(model, test){
  # Predict https://www.rdocumentation.org/packages/quanteda.textmodels/versions/0.9.3/topics/predict.textmodel_svm
  predicted <- predict(model, newdata = test, type = "class")
  print(predicted)
  accuracy <- sum(test$type == predicted)/length(predicted)
  print(accuracy)
  return(accuracy)
}
