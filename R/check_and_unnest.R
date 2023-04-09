#' @title Check and Unnest an `idaifield_docs`-list
#'
#' @description Checks if the input object is an `idaifield_docs`-list,
#' and if it is already unnested (i.e., of class `idaifield_resources` or
#' `idaifield_simple`). If the object is not unnested, the function unnests
#' it by stripping all top-level lists and returning only the list
#' called "resource" within the db docs. If the input
#' object cannot be processed because it is not an `idaifield_docs` or an
#' unnested `idaifield_resources` or `idaifield_simple` object,
#' the function issues a warning and returns the same object. You may force
#' the function to process it anyway using `force = TRUE`, but the outcome
#' is uncertain.
#'
#' @param idaifield_docs An object of class `idaifield_docs`.
#' Typically, this is a list obtained from a CouchDB export that has been
#' converted to a list from JSON by the function
#' [get_idaifield_docs()] or the query functions of this package
#' ([idf_query()], [idf_index_query()]).
#' If the object is of class `idaifield_docs`, the function removes the
#' top level lists, which contain information such as revisions and
#' creation dates, and returns a new object of class `idaifield_resources`.
#'
#' @param idaifield_docs An object of class `idaifield_docs` to be processed.
#' @param force TRUE/FALSE. Should the function attempt to unnest the input
#' object regardless of type or class? Default is FALSE.
#'
#' @returns If already unnested, the same object as handed to it. If not,
#' the same list with the top-level lists removed down to the "resource"-level.
#'
#' @export

#'
#' 
#' 
#'
#'
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' idaifield_docs <- get_idaifield_docs(conn, raw = TRUE)
#'
#' # Check if idaifield_docs is already unnested, and if not, do so:
#' idaifield_docs <- check_and_unnest(idaifield_docs)
#' }
check_and_unnest <- function(idaifield_docs, force = FALSE) {
  check <- check_if_idaifield(idaifield_docs)
  processed <- FALSE
  if (check["idaifield_docs"]) {
    result <- unnest_docs(idaifield_docs)
    processed <- TRUE
  } else if (check["idaifield_resources"]) {
    message("The list was already unnested to resource-level.")
    result <- idaifield_docs
  } else if (check["idaifield_simple"]) {
    message("The list was already unnested to resource-level and simplified.")
    result <- idaifield_docs
  } else {
    result <- idaifield_docs
    warning("Input object is not an idaifield_docs or an unnested idaifield_resources or idaifield_simple object.")
  }
  if (force & !processed) {
    warning("Attempting to unnest anyway.")
    result <- unnest_docs(result)
  }
  return(result)
}
