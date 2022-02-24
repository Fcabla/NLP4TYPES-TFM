#https://www.analyticsvidhya.com/blog/2021/06/why-and-how-to-use-bert-for-nlp-text-classification/
#https://towardsdatascience.com/text-classification-with-nlp-tf-idf-vs-word2vec-vs-bert-41ff868d1794
# https://towardsdatascience.com/a-comprehensive-hands-on-guide-to-transfer-learning-with-real-world-applications-in-deep-learning-212bf3b2f27a
#https://towardsdatascience.com/calculating-document-similarities-using-bert-and-other-models-b2c1a29c9630
import pandas as pd 
import numpy as np
import matplotlib as plt
#import seaborn as sns
import re
import nltk
from sklearn import model_selection#, feature_extraction, naive_bayes, pipeline, manifold, preprocessing
# from lime import lime_text
# import gensim
# import gensim.downloader as gensim_api
from tensorflow.keras import models, layers, preprocessing as kpreprocessing
from tensorflow.keras import backend as k
from tensorflow.python.keras.backend import dtype
import transformers

import pickle

DF_PATH = "/home/fcabla/Documentos/UPM/TFM/datasets/3mdbpedia_ne.csv"
#DF_PATH = "/home/fcabla/Documentos/UPM/TFM/test_df_ne.csv"
print("Reading dataframe")
df = pd.read_csv(DF_PATH)
df = df.dropna()
#df.drop(['Unnamed: 0', 'individual'], axis=1)
df.drop('individual', axis=1)
df = df.sample(frac=0.55, replace=True, random_state=1)
#df["abstract"] = df["abstract"].apply(lambda x: x[:512])
print(df.head())
print(df.shape)

def utils_preprocess_text(text, flg_stemm=False, flg_lemm=True, lst_stopwords=None):
    ## clean (convert to lowercase and remove punctuations and characters and then strip)
    text = re.sub(r'[^\w\s]', '', str(text).lower().strip())
            
    ## Tokenize (convert from string to list)
    lst_text = text.split()    ## remove Stopwords
    if lst_stopwords is not None:
        lst_text = [word for word in lst_text if word not in 
                    lst_stopwords]
                
    ## Stemming (remove -ing, -ly, ...)
    if flg_stemm == True:
        ps = nltk.stem.porter.PorterStemmer()
        lst_text = [ps.stem(word) for word in lst_text]
                
    ## Lemmatisation (convert the word into root word)
    if flg_lemm == True:
        lem = nltk.stem.wordnet.WordNetLemmatizer()
        lst_text = [lem.lemmatize(word) for word in lst_text]
            
    ## back to string from list
    text = " ".join(lst_text)
    return text

#lst_stopwords = nltk.corpus.stopwords.words("english")
#df["abstract"] = df["abstract"].apply(lambda x: utils_preprocess_text(x, flg_stemm=False, flg_lemm=True,lst_stopwords=lst_stopwords))

## split dataset
df_train, df_test = model_selection.train_test_split(df, test_size=0.3)## get target
y_train = df_train["type"].values
y_test = df_test["type"].values

## BERT (distikl)
btokenizer = transformers.AutoTokenizer.from_pretrained('distilbert-base-uncased', do_lower_case=True)

def prepare_data2(corpus, tokenizer):
    corpus = corpus["abstract"].to_list()
    encoding = tokenizer.batch_encode_plus(corpus, add_special_tokens = True, truncation = True, 
            padding = 'longest', return_attention_mask = True)
    encoding = [encoding["input_ids"], encoding["attention_mask"]]
    return encoding

print('ENCODING')
maxlen = 50
X_train = prepare_data2(df_train, btokenizer)
X_test = prepare_data2(df_test, btokenizer)
print('end encodign')

## model
#inp_size = X_train["attention_mask"].get_shape()[1]
inp_size = 512
#X_train = [X_train["input_ids"], X_train["attention_mask"]]
#X_test = [X_test["input_ids"], X_test["attention_mask"]]
print(inp_size)

## inputs
idx = layers.Input((inp_size), dtype="int32", name="input_idx")
masks = layers.Input((inp_size), dtype="int32", name="input_masks")

## pre-trained bert with config
config = transformers.DistilBertConfig(dropout=0.2, attention_dropout=0.2)
config.output_hidden_states = False
nlp = transformers.TFDistilBertModel.from_pretrained('distilbert-base-uncased', config=config)
bert_out = nlp(idx, attention_mask=masks)[0]

## fine-tuning
x = layers.GlobalAveragePooling1D()(bert_out)
x = layers.Dense(512, activation="relu")(x)
y_out = layers.Dense(len(np.unique(y_train)),activation='softmax')(x)

## compile
model = models.Model([idx, masks], y_out)

for layer in model.layers[:3]:
    layer.trainable = False

model.compile(loss='sparse_categorical_crossentropy',optimizer='adam', metrics=['accuracy'])
model.summary()

## encode y
dic_y_mapping = {n:label for n,label in enumerate(np.unique(y_train))}
inverse_dic = {v:k for k,v in dic_y_mapping.items()}
y_train = np.array([inverse_dic[y] for y in y_train])

## train
#training = model.fit(x=X_train, y=y_train, batch_size=64, epochs=10, shuffle=True, verbose=1, validation_split=0.3)
pipe = transformers.pipeline(model = model, tokenizer=btokenizer)
training = model.fit(x=X_train, y=y_train, batch_size=512, epochs=20, shuffle=True, verbose=1, validation_split=0.3)

## test
predicted_prob = model.predict(X_test)
predicted = [dic_y_mapping[np.argmax(pred)] for pred in predicted_prob]
print(sum([i==j for i, j in zip(y_test, predicted)])/len(predicted))
print(training)

pickle.dump(training, open("history3m.p", "wb"))