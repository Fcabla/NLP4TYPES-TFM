library(data.tree)
library(rdflib)
DBO_URL <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"

# https://rdrr.io/cran/data.tree/man/Node.html
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html
# http://mappings.dbpedia.org/server/ontology/
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html#data.tree-basics

# Function to transform an Ontology from an URL to class hierarchy (network mode)
ontology_to_class_hierarchy_URL <- function(ontology_url = DBO_URL, remove_url = TRUE){
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
  
  if(remove_url){
    class_hierarchy <- remove_resources_url(class_hierarchy, c("subclass","superclass"))
  }
  return(class_hierarchy)
}

find_node_path <- function(dbo_tree, type_name){
  rslt = FindNode(dbo_tree, type_name)$path
  # remove <owl:thing>
  if(!is.null(rslt)){
    rslt <- rslt[-1]
  }else{
    rslt = ""
  }
  return(rslt)
}
# x is a collection of types
find_types_path <- function(x, ont_tree){
  if(length(x)>0){
    typs <- character(0)
    for (i in 1:length(x)) {
      typs <- c(typs, find_node_path(ont_tree, x[[i]]))
    }
    x[i] <- typs
  }
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
get_tree_from_ontology <- function(ontology_from_URL=TRUE, remove_URL = TRUE){
  class_hierarchy <- ontology_to_class_hierarchy_URL(ontology_url = DBO_URL, remove_URL)
  
  #if(get_en_names){
  #  en_names <- data.frame(class_ontology_name=class_hierarchy$subclass, class_name=class_hierarchy$labelEn, stringsAsFactors = FALSE)
  #  en_names[nrow(en_names) + 1,] = c("owl:Thing", "thing")
  #}
  # class_hierarchy <- subset(class_hierarchy, select = -labelEn)
  dbo_tree <- get_tree_from_class_hierarchy(class_hierarchy)
  
  #if(get_en_names){
  #  return(list(dbo_tree, en_names))
  #}
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

'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  SELECT ?subclass ?superclass ?labelEn  WHERE { {
    ?subclass rdfs:subClassOf ?superclass.
    ?subclass a owl:Class .
    ?superclass a owl:Class .
    optional{
        ?subclass rdfs:label ?labelEn .
        filter langMatches(lang(?labelEn), "en")
    }
  } UNION {
    ?subclass rdfs:subClassOf owl:Thing.
    BIND("owl:Thing" as ?superclass) .
    optional{
        ?subclass rdfs:label ?labelEn .
        filter langMatches(lang(?labelEn), "en")
    }
  } }
'

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