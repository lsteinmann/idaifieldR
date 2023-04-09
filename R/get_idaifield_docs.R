#' @title Import all *docs* from an iDAI.field / Field Desktop project
#'
#' @description Imports all *docs* from an iDAI.Field-database that is
#' currently running and syncing into a list-object for further processing
#' in R. The function is only useful for the import from
#' [iDAI.field 2 or Field Desktop](https://github.com/dainst/idai-field)
#' with the respective client running on the same computer or
#' in the same network as the R-script.
#'
#' @details When using `raw = TRUE` (the default) this function will allow
#' you to get the change log for each resource, i.e. which user changed
#' something in the resource at what time and who created it.
#' Setting `raw = FALSE` will only return a list of the actual data.
#' You can do this at a later time using [check_and_unnest()]
#' from this package.
#' NOTE: If you are planning on using the coordinates stored in the database,
#' I strongly suggest you consider changing your R digits-setting to a higher
#' value than the default. Depending on the projection used, coordinates may
#' be represented by rather long numbers which R might automatically round on
#' import. `options(digits = 20)` should more than do the trick. (That applies
#' to other fields containing long numbers as well.)
#'
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param raw TRUE/FALSE. Should the result already be unnested to
#' resource level using [check_and_unnest()]? (Default is FALSE.)
#' @param json TRUE/FALSE. Should the function return a JSON-character string?
#' (Default is FALSE.) If TRUE output cannot be processed with the functions
#' from this package. Can be parsed using e.g. [jsonlite::fromJSON()].
#' @param projectname The name of the project in the Field Client that one
#' wishes to load. Will overwrite the project set in the `connection`-object.
#' See [idf_projects()] for all available projects.
#'
#' @returns an object (list) of class `idaifield_docs` if `raw = TRUE` and
#' `idaifield_resources` if `raw = FALSE` that contains all *docs*/*resources*
#' in the selected project except for the project configuration.
#' The `connection` and `projectname` are attached as attributes for
#' later use. (If `json = TRUE`, returns a character string in JSON-format.)
#'
#' @seealso
#' * For querying the database: [idf_query()],[idf_index_query()]
#' * For filtering / selecting an `idaifield_docs`- or `idaifield_resources`-list: [idf_select_by()]
#' * For processing the list: [check_and_unnest()], [simplify_idaifield()]
#'
#'
#' 
#' 
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(project = "rtest", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = conn)
#' }
#'
get_idaifield_docs <- function(connection = connect_idaifield(
  serverip = "127.0.0.1", project = "rtest",
  user = "R", pwd = "hallo"),
  raw = TRUE,
  json = FALSE,
  projectname = NULL) {

  client <- proj_idf_client(conn = connection,
                            project = projectname,
                            include = "all")

  options(digits = 20)

  idaifield_docs <- client$get(query = list(include_docs = "true"))
  idaifield_docs <- idaifield_docs$parse("UTF-8")

  if (!json) {
    idaifield_docs <- jsonlite::fromJSON(idaifield_docs, FALSE)

    idaifield_docs <- idaifield_docs$rows

    # remove the Configuration list from the resources
    conf_ind <- which(lapply(idaifield_docs,
                             function(x)
                               x$doc$resource$id)
                      == "configuration")
    if (!is.na(conf_ind)) {
      idaifield_docs[[conf_ind]] <- NULL
    }

    idaifield_docs <- name_docs_list(idaifield_docs)
    idaifield_docs <- type_to_category(idaifield_docs)


    idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")

    if (!raw) {
      idaifield_docs <- check_and_unnest(idaifield_docs)
    }
  }

  projectname <- ifelse(is.null(projectname),
                        connection$project,
                        projectname)

  attr(idaifield_docs, "connection") <- connection
  attr(idaifield_docs, "projectname") <- projectname

  return(idaifield_docs)
}
