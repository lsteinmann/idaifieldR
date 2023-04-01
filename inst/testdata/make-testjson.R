connection <- connect_idaifield(pwd ="hallo", project = "rtest")
client <- proj_idf_client(connection, include = "all")

import <- client$get(query = list(include_docs = "true"))
import <- response_to_list(import)

import <- import$rows

import <- lapply(import, function(x) {
  x$doc$created <- NULL
  x$doc$modified <- NULL
  x$doc$`_rev` <- NULL
  x$value <- NULL
  return(x$doc)
})
import <- list(docs = import)

jsonlite::write_json(import, path = "inst/testdata/import2.json")
