#' Unnesting a idaifield_docs-List down to resource level
#'
#' This function unnests the lists provided by iDAI.field 2 / Field Desktop.
#' The actual data of a resource is usually stored in a sub-list
#' behind $doc$resource, which contains the data one would mostly
#' want to work with in R. The top level data contains information
#' about who created and modified the resource at what time and
#' is irrelevant for any analysis of the database contents itself.
#'
#' @param idaifield_docs A list as provided by `get_idaifield_docs()`.
#' `get_idaifield_docs()` employs this function already when
#' setting `raw = FALSE`.
#'
#' @keywords internal
#'
#'
#' @return a list of class idaifield_resources (same as idaifield_docs,
#' but the top-level with meta-information has been removed to make the actual
#' resource data more accessible)
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest")
#'
#' idaifield_resources <- unnest_docs(idaifield_docs)
#' }
unnest_docs <- function(docs) {
  check <- names(unlist(docs, recursive = TRUE))
  check <- any(grepl("resource", check))

  if (check) {
    resources <- find_resource(docs)
    resources <- structure(resources, class = "idaifield_resources")
    attr(resources, "connection") <- attr(docs, "connection")
    attr(resources, "projectname") <- attr(docs, "projectname")
    attr(resources, "config") <- attr(docs, "config")
    return(resources)
  } else {
    stop("No resource-list present in the object.")
  }
}

#' Finding the "resource"-list in a CouchDB-output
#'
#' @param list a list formatted from a CouchDB-JSON-output
#'
#' @return the list of resource-lists
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' testlist <- list(docs = list(list(resource = list(test = "test",
#'                                                   test2 = "test2")),
#'                              list(resource = list(test = "test",
#'                                                   test2 = "test2"))),
#'                  warning = "warning")
#' find_resource(testlist)
#' }
find_resource <- function(list) {
  has_resource <- lapply(list, function(x) "resource" %in% names(x))
  has_resource <- unlist(has_resource)
  has_resource <- any(has_resource)
  if (has_resource) {
    resource_list <- lapply(list, function(x) na_if_empty(x$resource))
    return(resource_list)
  } else {
    has_docs <- "docs" %in% names(list)
    has_rows <- "rows" %in% names(list)
    if (has_docs) {
      list <- list$docs
      find_resource(list)
    } else if (has_rows) {
      list <- list$rows
      find_resource(list)
    } else {
      has_doc <- lapply(list, function(x) "doc" %in% names(x))
      has_doc <- unlist(has_doc)
      has_doc <- all(has_doc)
      if (has_doc) {
        list <- lapply(list, function(x) x$doc)
        find_resource(list)
      } else {
        # This is were the function should give up
        warning("No resource-lists found.")
        return(list)
      }
    }
  }
}
