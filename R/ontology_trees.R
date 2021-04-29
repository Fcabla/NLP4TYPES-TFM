library(data.tree)
library(rdflib)
DBO_URL <- "http://mappings.dbpedia.org/server/ontology/dbpedia.owl"

# https://rdrr.io/cran/data.tree/man/Node.html
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html

# http://mappings.dbpedia.org/server/ontology/dbpedia.owl
# http://mappings.dbpedia.org/server/ontology/classes/
# http://mappings.dbpedia.org/server/ontology/

# ToDo: Parse owl and extract class hierarchy (done)
# ToDo: Save class hierarchy as yaml file 
# ToDo: Transform class hierarchy into a data.tree object (done)
# ToDo: Load yaml into a data.tree object
# ToDo: Save a data.tree into a yaml file
# ToDo: Functionify! xD
rdf <- rdf_parse(doc = DBO_URL)
#https://stackoverflow.com/questions/19453072/importing-dbpedias-class-hierarchy
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
class_hierarchy <- rdf_query(rdf, sparql_query)

class_hierarchy$subclass <- gsub(pattern = "http://dbpedia.org/ontology/", replacement = "", x = as.character(class_hierarchy$subclass)) 
class_hierarchy$superclass <- gsub(pattern = "http://dbpedia.org/ontology/", replacement = "", x = as.character(class_hierarchy$superclass)) 

dbo_tree <- as.Node(x = class_hierarchy, mode = "network")
print(dbo_tree)


sparql_query_test <- 
  'prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?subclass ?superclass where {
  ?subclass rdfs:subClassOf ?superclass.
  ?subclass <http://open.vocab.org/terms/defines> "http://dbpedia.org/ontology/" .
  ?superclass <http://open.vocab.org/terms/defines> "http://dbpedia.org/ontology/" .
}'