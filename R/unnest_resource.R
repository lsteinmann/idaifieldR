#' Unnesting a idaifield_docs-List down to resource level
#'
#' This function unnests the lists provided by i.DAIfield 2.
#' The actual data of a resource is usually stored in a sub-list
#' behind $doc$resource, which contains the data one would mostly
#' want to work with in R. The top level data contains information
#' about who created and modified the resource at what time and
#' is irrelevant for any analysis of the database contents itself.
#'
#' @param idaifield_docs A list as provided by `sofa::db_alldocs(...)` when
#' importing from an i.DAIfield 2-database using `get_idaifield_docs()`.
#' `get_idaifield_docs()` employs this function already
#' when setting `simplified = TRUE`, which is the default.
#' Mostly there is no need to deal with `unnest_resource()`. If one chooses
#' `get_idaifield_docs(..., simplified  = FALSE)`, it is possible to use
#' `unnest_resource()` on the resulting list to simplify it.
#'
#'
#' @return a list of class idaifield_resources (same as idaifield_docs,
#' but the top-level with meta-information has been removed to make the actual
#' resource data more accessible)
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password",
#' simplified = FALSE)
#'
#' idaifield_resources <- unnest_resource(idaifield_docs)
#' }
unnest_resource <- function(idaifield_docs) {

  check_result <- check_if_idaifield(idaifield_docs)

  if (check_result["idaifield_docs"]) {
    idaifield_resources <- lapply(idaifield_docs,
                                  function(docs) docs$doc$resource)
    idaifield_resources <- structure(idaifield_resources,
                                     class = "idaifield_resources")
    return(idaifield_resources)
  } else if (check_result["idaifield_resources"]) {
    message("The list was already unnested to resource-level.")
    return(idaifield_docs)
  } else {
    stop("The object provided cannot be processed by this function.")
    # could wrap everything in trycatch to allow people to use it without
    # enforcing the class
  }
}
