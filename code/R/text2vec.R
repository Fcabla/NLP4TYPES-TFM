library(text2vec)
it_train = itoken(df$abstract, 
                  preprocessor = tolower, 
                  tokenizer = word_tokenizer, 
                  ids = df$individual, 
                  progressbar = T)
vocab = create_vocabulary(it_train)

vectorizer = vocab_vectorizer(vocab)
dtm_train = create_dtm(it_train, vectorizer)

#dtm_train_l2_norm = normalize(dtm_train, "l2")

# define tfidf model
tfidf = TfIdf$new(smooth_idf = T, norm = "l2")
# fit model to train data and transform train data with fitted model
dtm_train_tfidf = fit_transform(dtm_train, tfidf)
# tfidf modified by fit_transform() call!
# apply pre-trained tf-idf transformation to test data
#dtm_test_tfidf = create_dtm(it_test, vectorizer)
#dtm_test_tfidf = transform(dtm_test_tfidf, tfidf)

labels = df$type
# Extract from a dataframe a set of types that are unique, 1 instance per type of type (not used now)
# id_types_dict <- seq.int(length(id_types_dict))
# names(id_types_dict) <- unique(df_ne$type)
#names(id_types_dict) <- seq.int(length(id_types_dict))

# idlabels <- integer(length(labels))
# for(i in 1:length(labels)){
#   idlabels[i] <- id_types_dict[labels[i]]
# }
# as.factor(df_ne$type)
#as(sparseMatrix(dtm_train_tfidf), "RsparseMatrix") 

#k=5
#folds <- fold(data.frame(doc_id = dimnames(dtm_train_tfidf)[1]), k = k)[[".folds"]]

#results <- data.frame(acc=double(k), hprec=double(k), hrec=double(k), hF=double(k), stringsAsFactors = F)
library("LiblineaR")
dtm_train_tfidf <- as(dtm_train_tfidf, "RsparseMatrix")
# https://rdrr.io/cran/LiblineaR/src/R/LiblineaR.R

tmod <- LiblineaR(tessss,df_ne$type,type = 1,cost = 1,verbose = TRUE, cachesize = 5120)

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