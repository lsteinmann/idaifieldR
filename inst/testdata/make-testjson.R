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
  x$`_id` <- NULL
  x$`_rev` <- NULL
  x$`_revisions` <- NULL
  return(x)
})
import <- list(docs = import)
write(jsonlite::toJSON(import,
                       simplifyVector = TRUE,
                       auto_unbox = TRUE,
                       pretty = TRUE), file = "inst/testdata/import.json")









unbox_resource <- function(resource) {
  resource <- lapply(resource, function(x)
    if (length(x) == 1) {
      x <- unlist(x)
    })
}
import_unboxed <- lapply(import, function(x) {
  x$resource <- unbox_resource(x$resource)
  return(x)
})


resource <- import[[1]]$resource
length(resource[[2]])

unlist(resource[2])
jsonlite::unbox(unlist(resource[[2]]))



?unbox


jsonlite::unbox(import$docs[[1]]$resource$identifier)


str(import$docs[[1]])

