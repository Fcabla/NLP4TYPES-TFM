import textProcessing
import dbpediaData
import pandas as pd

if __name__ == "__main__":
    #dbpediaData.csv_from_ttl("datasets/short_abstracts_en.ttl","datasets/short_abstracts_en.csv", ["individual", "property", "abstract", "dot"])
    df = pd.read_csv("datasets/test_abstract.csv")

    df = textProcessing.process_abstracts_dataframe(df)

    print(df)
