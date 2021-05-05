import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer, SnowballStemmer
import string

#nltk.download('punkt')
#nltk.download('stopwords')
#nltk.download('wordnet')

TEST_TEXT = "In Greek mythology, Queen Endeïs /ɛnˈdiːᵻs/ was the wife of King Aeacus and mother of Telamon and King Peleus. (As Peleus was the father of Achilles, Endeïs was Achilles's grandmother.) The name is a dialect variant of Engaios (Ἐγγαίος, \in"
def process_raw_text(raw_text, stopwords, stemmer, lemmatizer, use_stopwords=True, use_stemmer=False, use_lemmatizer=True):
    
    # Set words to lower case (maybe is better in later stages of the pipeline)
    process_text = raw_text.lower()
    
    # Tokenize
    word_tokens = nltk.word_tokenize(process_text)

    # Remove specific words/tokens
    if word_tokens[-1] == "@en":
        word_tokens = word_tokens.remove("@en")

    # Remove punctuation
    table = str.maketrans('', '', string.punctuation)
    word_tokens = [w.translate(table) for w in word_tokens]

    # Remove remaining tokens that are not alphabetic 
    word_tokens = [word for word in word_tokens if word.isalpha()]

    # NORMALIZE (dieresis, acentos, letras griegas, etc..)??¿¿??

    # Stopword removal
    if use_stopwords:
        word_tokens = [word for word in word_tokens if word not in stopwords]

    # stemmer (is this needed if we use lemmatization?)
    if use_stemmer:
        word_tokens = [stemmer.stem(word) for word in word_tokens]

    # lemmatization
    if use_lemmatizer:
        word_tokens = [lemmatizer.lemmatize(word) for word in word_tokens]

    return " ".join(word_tokens)

def process_abstracts_dataframe(df, use_stopwords=True, use_stemmer=False, use_lemmatizer=True):
    stopword = None
    stemmer = None
    lemmatizer = None

    if use_stopwords:
        stopword = stopwords.words('english')
    
    if use_stemmer:
        stemmer = SnowballStemmer('english')

    if use_lemmatizer:
        lemmatizer = WordNetLemmatizer()

    #df["abstract"] = process_raw_text(df["abstract"], stopword, stemmer, lemmatizer, use_stopwords, use_stemmer, use_lemmatizer)
    print(df["abstract"].head())
    df["abstract"] = df["abstract"].apply(lambda x: process_raw_text(x, stopword, stemmer, lemmatizer, use_stopwords, use_stemmer, use_lemmatizer))
    #df["abstract"].map(process_raw_text(stopword, stemmer, lemmatizer, use_stopwords, use_stemmer, use_lemmatizer))
    return df

def process_abstract_text(raw_text, use_stopwords=True, use_stemmer=False, use_lemmatizer=True):
    stopword = None
    stemmer = None
    lemmatizer = None

    if use_stopwords:
        stopword = stopwords.words('english')
    
    if use_stemmer:
        stemmer = SnowballStemmer('english')

    if use_lemmatizer:
        lemmatizer = WordNetLemmatizer()

    text = process_raw_text(raw_text, stopword, stemmer, lemmatizer, use_stopwords, use_stemmer, use_lemmatizer)
    return text

if __name__ == "__main__":
    print(TEST_TEXT)
    processed_text = process_abstract_text(TEST_TEXT)
    print(processed_text)