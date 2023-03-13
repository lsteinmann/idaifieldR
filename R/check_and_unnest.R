#' Check and unnest a list
#'
#' Checks for list of class "idaifield_docs" and if the object is already
#' unnested (i.e. of class "idaifield_resources"); if it is not, does so.
#' If it cannot be processed, because it is not an idaifield_docs or
#' idaifield_resources object, issues a warning and returns the same object.
#'
#' @param idaifield_docs An object to be used by one of the
#' functions in this package
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
check_and_unnest <- function(idaifield_docs) {
  check <- check_if_idaifield(idaifield_docs)
  if (check["idaifield_docs"]) {
    idaifield_docs <- unnest_docs(idaifield_docs)
    return(idaifield_docs)
  } else if (check["idaifield_resources"]) {
    return(idaifield_docs)
  } else if (check["idaifield_simple"]) {
    return(idaifield_docs)
  } else {
    warning("Not processed, did nothing.")
    return(idaifield_docs)
  }
}
