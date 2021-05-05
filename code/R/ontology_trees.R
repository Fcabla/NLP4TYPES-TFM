library(data.tree)
library(rdflib)
DBO_URL <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"

# https://rdrr.io/cran/data.tree/man/Node.html
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html
# http://mappings.dbpedia.org/server/ontology/
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html#data.tree-basics

# Function to transform an Ontology from an URL to class hierarchy (network mode)
ontology_to_class_hierarchy_URL <- function(ontology_url = DBO_URL){
  # Parse the RDF 
  rdf <- rdf_parse(doc = ontology_url)
  # https://stackoverflow.com/questions/19453072/importing-dbpedias-class-hierarchy
  # https://stackoverflow.com/questions/43125270/sparql-dbpedia-filter-out-specific-results
  #<http://www.w3.org/2002/07/owl#Thing>
  sparql_query <- 
  'PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  SELECT ?subclass ?superclass WHERE { {
    ?subclass rdfs:subClassOf ?superclass.
    ?subclass a owl:Class .
    ?superclass a owl:Class .
  } UNION {
    ?subclass rdfs:subClassOf owl:Thing.
    BIND("owl:Thing" as ?superclass)
  } }'
  # Get class hierarchy from query
  class_hierarchy <- rdf_query(rdf, sparql_query)
  # Remove "http://dbpedia.org/ontology/"
  #class_hierarchy$subclass <- gsub(pattern = "http://dbpedia.org/ontology/", replacement = "", x = as.character(class_hierarchy$subclass)) 
  #class_hierarchy$superclass <- gsub(pattern = "http://dbpedia.org/ontology/", replacement = "", x = as.character(class_hierarchy$superclass)) 
  class_hierarchy$subclass <- paste("<",class_hierarchy$subclass,">",sep = "")
  class_hierarchy$superclass <- paste("<",class_hierarchy$superclass,">",sep = "")
  return(class_hierarchy)
}

# Function to transform an Ontology from an owl file to class hierarchy (network mode)
ontology_class_hierarchy_File <- function(){}

# Function to transform dataframe containing class hierarchy as network (from -> to) to tree object
get_tree_from_class_hierarchy <- function(class_hierarchy){
  # Transform dataframe with results into tree
  dbo_tree <- as.Node(x = class_hierarchy, mode = "network")
  return(dbo_tree)
}

# Function to get tree from ontology (to do/finish)
get_tree_from_ontology <- function(ontology_from_URL=TRUE){
  class_hierarchy <- ontology_to_class_hierarchy_URL()
  dbo_tree <- get_tree_from_class_hierarchy(class_hierarchy)
  return(dbo_tree)
}

# Function to store a tree in to a csv file or similar
save_tree <- function(ontology_tree, output_file){
  tree_network_df <- ToDataFrameNetwork(ontology_tree)
  write.csv(tree_network_df, output_file, row.names = FALSE)
}

# Function to load a tree from a csv file or similar
load_tree <- function(tree_path_file){
  tree_network_df <- read.csv(file=tree_path_file)
  dbo_tree <- get_tree_from_class_hierarchy(tree_network_df)
  return(dbo_tree)
}

