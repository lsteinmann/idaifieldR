#' get_idaifield_docs: Import all docs from an iDAI.field / Field Desktop project
#'
#' Imports all docs from an idaifield-database that is currently running
#' and synching into a list-object for further processing in R.
#' This wraps **sofa**s functions and very slightly processes the output.
#' The function is only useful for the import from iDAI.field 2 or
#' Field Desktop with the respective client running on the same computer as
#' the R-script.
#' When using `raw = TRUE` (the default) this function will allow you to
#' get the changelog for each resource, i.e. which user changed something
#' in the resource at what time and who created it. Setting raw to FALSE
#' will only return a list of the actual data. You can do this at a later time
#' using `check_and_unnest()` from this package.
#'
#' NOTE: If you are planning on using the coordinates stored in the database,
#' I strongly suggest you consider changing your R digits-setting to a higher
#' value than the default. Depending on the projection used, coordinates may
#' be represented by rather long numbers which R might automatically round on
#' import. `options(digits = 20)` should more than do the trick. (That applies
#' to other fields containing long numbers as well.)
#'
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project in the Field Client that one
#' wishes to load.
#' @param raw default FALSE. If you wish to get an unnested version of only
#' the resources, without the metadata (i.e. changes by user), set it to TRUE
#' @param json default FALSE; if TRUE output cannot be simplified with the
#' functions from this package and is instead of a list returned in json format
#' that can freely be manipulated using e.g. the jsonlite package.
#' (Might be more useful for some users.)
#'
#' @return an object (list) of class "idaifield_docs" if raw = TRUE and
#' "idaifield_resources" if raw = FALSE that contains all docs/resources
#' in the selected project except for the Project Configuration.
#' The connection, projectname and configuration are attached as
#' attributes for later use.(If json is set to TRUE, returns a character
#' string in json-format.)
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
  projectname = "projectname",
  raw = TRUE,
  json = FALSE) {

  fail <- idf_ping(connection)
  if(is.character(fail)) {
    stop(fail)
  }

  if (json) {
    output_format <- "json"
  } else {
    output_format <- "list"
  }
  options(digits = 20)
  idaifield_docs <- sofa::db_alldocs(connection, projectname,
                                     include_docs = TRUE,
                                     as = output_format)

  if (!json) {
    # remove the Configuration list from the resources
    conf_ind <- which(lapply(idaifield_docs$rows,
                             function(x)
                               x$doc$resource$identifier)
                      == "Configuration")
    if (!is.na(conf_ind)) {
      idaifield_docs$rows[[conf_ind]] <- NULL
    }

    idaifield_docs <- idaifield_docs$rows
    idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")
    if (!raw) {
      idaifield_docs <- check_and_unnest(idaifield_docs)
    }
  }

  # get it again to add as attribute as it makes more sense to store
  # metadata there
  config <- try(get_configuration(connection, projectname))

  attr(idaifield_docs, "connection") <- connection
  attr(idaifield_docs, "projectname") <- projectname
  attr(idaifield_docs, "config") <- config

  return(idaifield_docs)
}
