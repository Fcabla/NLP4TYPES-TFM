import rdfpandas.graph
import pandas as pd
import rdflib

# Function to save csv from a ttl file
def csv_from_ttl(input_path, output_path, col_names):
    df = pd.read_csv(input_path, sep=" ", skiprows=1, names=col_names)
    print(df.head())
    df = df.drop([col_names[1], col_names[3]], axis=1)
    print(df.head())
    df.to_csv(output_path, index=False)

# Function to load the dataframe from a ttl file
def load_ttl(input_path, col_names):
    df = pd.read_csv(input_path, sep=" ", skiprows=1, names=col_names)
    print(df.head())
    df = df.drop([col_names[1], col_names[3]], axis=1)
    print(df.head())
    return df

# Function to load the dataframe from a csv file
def load_csv(input_path_abstracts, input_path_types):
    #df_abstracts = pd.read_csv(input_path_abstracts)
    df_types = pd.read_csv(input_path_types)
    print(df_types.info())
    print(df_types["individual"].nunique(), df_types.count())
    #df = pd.merge()

if __name__ == "__main__":
    
    # Transform ttl files to csv 
    #csv_from_ttl("datasets/short_abstracts_en.ttl","datasets/short_abstracts_en.csv", ["individual", "property", "abstract", "dot"])
    #csv_from_ttl("datasets/instance_types_en.ttl","datasets/instance_types_en.csv", ["individual", "property", "types", "dot"])

    # Merge csvs
    load_csv("datasets/short_abstracts_en.csv", "datasets/instance_types_en.csv")
