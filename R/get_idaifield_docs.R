#' get_idaifield_docs
#'
#' Imports all resources from an idaifield-database that is currently running
#' and synching into a list-object for further processing in R.
#' This just wraps **sofa**s functions under another name,
#' but with defaults that are useful for the import from iDAI.field 2.
#' Also, I am using unnest_resource() from this package here, as there
#' seems to be no use in the nested version. However,
#' simplified = FALSE would allow to get the top-level version.
#'
#' NOTE: If you are planning on using the coordinates stored in the database,
#' I strongly suggest you consider changing your R digits-setting to a higher
#' value than the default. Depending on the projection used, coordinates may
#' be represented by rather long numbers which R might automatically round on
#' import. `options(digits = 20)` should do the trick. (That applies to
#' other fields containing long numbers as well.)
#'
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project in iDAI.field 2 that one
#' wishes to load.
#'
#' @param keep_geometry TRUE if the geometry should be kept
#'
#' @param simplified Defaults to TRUE. If you do not wish to automatically
#' unnest (i.e. remove a level of the list that contains some metadata which is
#' IMO not useful when processing in R) just put FALSE (or anything but TRUE).
#' If you wish to take a look at it and then later unnest, you can always use
#' unnest_resource() from this package.
#'
#' @param json default FALSE; if TRUE output cannot be simplified with the
#' functions from this package and is instead of a list returned in json format
#' that can freely be manipulated using e.g. the jsonlite package.
#' (Might be more useful for some users.)
#'
#' @return an object (list) of class "idaifield_docs" (if simplified = FALSE)
#' or "idaifield_resources" (if simplified = TRUE) that contains the
#' resources in the selected project. (If json is set to TRUE, returns a
#' character string in json-format.)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = conn,
#' projectname = "rtest")
#' }
#'
get_idaifield_docs <- function(connection = connect_idaifield(
                                              serverip = "127.0.0.1",
                                              user = "R", pwd = "hallo"),
                               projectname = "projektname",
                               keep_geometry = TRUE,
                               simplified  = TRUE,
                               json = FALSE) {

  if (json) {
    simplified <- FALSE
    output_format <- "json"
  } else {
    output_format <- "list"
  }

  idaifield_docs <- sofa::db_alldocs(connection, projectname,
                                     include_docs = TRUE,
                                     as = output_format)

  if (!json) {
    idaifield_docs <- idaifield_docs$rows
    idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")
  }

  if (simplified) {
    idaifield_docs <- simplify_idaifield(idaifield_docs = idaifield_docs,
                                         keep_geometry = keep_geometry,
                                         replace_uids = TRUE)
  }

  return(idaifield_docs)
}
