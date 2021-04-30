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

# Function to evaluate the performance of the model
evaluate_results <- function(predicted, test, tree){
  # Initialize variables
  hits <- 0
  intersection_num <- 0
  hPrec_den <- 0
  hRec_den <- 0
  num_samples <- length(predicted)
  true_labels <- as.list(test$type)
  
  # For each pair predicted, true_label
  for(i in 1:num_samples){
    pr_label <- predicted[i]
    tr_label <- true_labels[i]
    
    # Check if they are the same --> regular accuracy
    if(pr_label == tr_label){
      hits <- hits + 1
    }
    
    # Find path to root from the label (hierarchical) --> tree
    pr_path <- FindNode(dbo_tree, pr_label)$path
    tr_path <- FindNode(dbo_tree, tr_label)$path
    
    # Accumulate the num of classes in both paths, lenght of predicted path and length of true labels path
    intersection_num <- intersection_num + sum(pr_path == tr_path)
    hPrec_den <- hPrec_den + length(pr_path)
    hRec_den <- hRec_den + length(tr_path)
  }
  
  acc <- hits / num_samples
  hP <- intersection_num / hPrec_den
  hR <- intersection_num / hRec_den
  hF <- (2 * hP * hR) / (hP + hR)
  
  # Alternative to get the accuracy
  # accuracy <- sum(test$type == predicted)/length(predicted)
  
  metrics <- c(acc, hP, hR, hF)
  return(metrics)
}

# Print results
print_measurements <- function(metrics){
  print(paste("Accuracy: ", metrics[1]))
  print(paste("Hierarchical Precission: ", metrics[2]))
  print(paste("Hierarchical Recall: ", metrics[3]))
  print(paste("Hierarchical F measure: ", metrics[4]))
}

predict_abstracts <- function(model, test){
  # Predict https://www.rdocumentation.org/packages/quanteda.textmodels/versions/0.9.3/topics/predict.textmodel_svm
  predicted <- predict(model, newdata = test, type = "class")
  print(predicted)
  return(predicted)
}