#' Check and unnest a list
#'
#' Checks for list of class "idaifield_docs" and if the object is already
#' unnested (i.e. of class "idaifield_resources"); if it is not, does so.
#' If it cannot be processed, because it is not an idaifield_docs or
#' idaifield_resources object, issues a warning and returns the same object.
#'
#' @param idaifield_docs An object to be used by one of the
#' functions in this package
#' @param force logical. Should the function attempt to process
#' regardless of class?
#'
#' @return if already unnested, the same object as handed to it. if not,
#' the same list with the toplevel removed.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "rtest",
#' connection = connect_idaifield(serverip = "127.0.0.1",
#' user = "R",
#' pwd = "password"))
#'
#' check_and_unnest(idaifield_docs)
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
