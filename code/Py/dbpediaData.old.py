from SPARQLWrapper import SPARQLWrapper, JSON
#dbo:abstract


sparql = SPARQLWrapper("http://dbpedia.org/sparql")
sparql.setQuery("""
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dbo: <http://dbpedia.org/resource/classes#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

    SELECT  ?abstract ?y
    WHERE {
        <http://dbpedia.org/resource/Asturias> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?y.
        <http://dbpedia.org/resource/Asturias> <http://dbpedia.org/ontology/abstract> ?abstract.
        FILTER langMatches(lang(?abstract),'en')
    }
""")
sparql.setReturnFormat(JSON)
results = sparql.query().convert()


for result in results["results"]["bindings"]:
    print(result)

print('---------------------------')

for result in results["results"]["bindings"]:
    print('%s: %s' % (result["label"]["xml:lang"], result["label"]["value"]))


test = prepareQuery('''
SELECT 
?type
WHERE { 
<http://dbpedia.org/resource/Autism> rdf:type/rdfs:subClassOf* ?type. 
}
''',
initNs = { "RDF" : RDF, "RDFS": RDFS}
)
