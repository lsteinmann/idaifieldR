#' @title (Maybe) Unnests an `idaifield_docs`-list
#'
#' @description Checks if the input object is an `idaifield_docs`-list.
#' If so, the function unnests it by stripping all top-level lists and
#' returning only the list called "resource" within the db docs.
#' Any other class will simply be returned unchanged.
#'
#' @param x An object of class `idaifield_docs`.
#' Typically, this is a list obtained from a CouchDB export that has been
#' converted to a list from JSON by the function
#' [get_idaifield_docs()] or the query functions of this package
#' ([idf_query()], [idf_index_query()], [idf_json_query()]).
#' If the object is of class `idaifield_docs`, the function removes the
#' top level lists, which contain information such as revisions and
#' creation dates, and returns a new object of class `idaifield_resources`.
#'
#' @param x An object of class `idaifield_docs` to be processed. Will return
#' objects of other classes unchanged.
#'
#' @returns If already unnested, the same object as handed to it. If not,
#' the same list with the top-level lists removed down to the "resource"-level,
#' as an `idaifield_resources`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' idaifield_docs <- get_idaifield_docs(conn, raw = TRUE)
#' idaifield_resources <- maybe_unnest_docs(idaifield_docs)
#' }
maybe_unnest_docs <- function(x) {
  if (inherits(x, "idaifield_docs")) {
    result <- unnest_docs(x)
    return(result)
  } else if (inherits(x, "idaifield_resources")) {
    # I am aware that this is redundant. We will still keep it as a reminder.
    # I am currently undecided if we should warn here.
    # We could have: "idaifield_docs", "idaifield_resources", "idaifield_simple"
    return(x)
  }
  # What should this actually behave like? Return NA?
  return(x)
}
