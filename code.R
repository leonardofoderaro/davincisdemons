
####################################################################
# Sample code to demonstrate an easy way to query DBpedia.
# For more information:
#
# https://www.linkedin.com/pulse/davincis-demons-semantic-web-leonardo-foderaro
# https://www.linkedin.com/pulse/davincis-demons-semantic-web-part-ii-leonardo-foderaro
# https://www.linkedin.com/pulse/davincis-demons-semantic-web-part-iii-leonardo-foderaro
#
#####################################################################

library(stringr)

# the DBpedia's SPARQL endpoint
endpoint <- "http://dbpedia.org/sparql"

# our query, derived directly from our information need
sparql_query <- '
    PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX type: <http://dbpedia.org/class/yago/>
    PREFIX prop: <http://dbpedia.org/ontology/>
    PREFIX dbp: <http://dbpedia.org/property/>
    PREFIX dc: <http://purl.org/dc/terms/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

    SELECT DISTINCT ?label as ?name, ?birth, ?death, ?abstract, (COUNT(?link) as ?externalLinksCount)  WHERE {
                    ?person a dbpedia-owl:Person .
                    ?person rdfs:label ?label .
                    ?person prop:birthDate ?birth .
                    ?person prop:deathDate ?death .
                    ?person prop:abstract ?abstract .
                    ?person dbpedia-owl:wikiPageExternalLink ?link .
                    bind( year(?death)-year(?birth) as ?age )

                    FILTER(lang(?label) = "en") .
                    FILTER(lang(?abstract) = "en") .
                    FILTER(DATATYPE(?birth) = xsd:date) .
                    FILTER(DATATYPE(?death) = xsd:date) .
                    FILTER(?age < 100) .

                    FILTER (!(( ?birth > "1519-05-02T00:00:00"^^xsd:dateTime ) OR
                    ( ?death < "1452-04-15T00:00:00"^^xsd:dateTime ))) .

    }

    GROUP BY ?label ?abstract ?age ?birth ?death 

    ORDER by DESC(?externalLinksCount)

   LIMIT 50
'


# a simple wrapper function 
get_sparql_results <- function(sparql) {
  
  # getting the results in a data.frame, directly from DBpedia CSV results
  d <- read.csv(paste(endpoint, '?query=', URLencode(str_replace_all(sparql, '[\\s\\n]', ' '),reserved = T), '&format=csv', sep = ''),stringsAsFactors = F)
  
  return(d)
}


results <- get_sparql_results(sparql_query)

# omitting the 'abstract' column to improve readability
head(results[,c(1:3)])


