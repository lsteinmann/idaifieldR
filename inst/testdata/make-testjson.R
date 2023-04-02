library(jsonlite)

jsonl <- readLines(system.file("testdata", "rtest.jsonl",
                               package = "idaifieldR"))
jsonl <- lapply(jsonl, function(x) fromJSON(x, FALSE))




list <- lapply(jsonl, function(x) {
  if ("docs" %in% names(x)) {
    x <- x$docs
  } else {
    x <- NULL
  }
})
ind <- unlist(lapply(list, is.null))
list <- list[!ind]

docs <- do.call(append, list)

import <- lapply(docs, function(x) {
  x$created <- NULL
  x$modified <- NULL
  #x$`_id` <- NULL
  x$`_rev` <- NULL
  x$`_revisions` <- NULL
  return(x)
})
import <- list(docs = import)
write(jsonlite::toJSON(import,
                       simplifyVector = TRUE,
                       auto_unbox = TRUE,
                       pretty = TRUE), file = "inst/testdata/import.json")
