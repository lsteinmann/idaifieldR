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
#' You can do this at a later time using [maybe_unnest_docs()]
#' from this package.
#'
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param raw TRUE/FALSE. Should the result already be unnested to
#' resource level using [maybe_unnest_docs()]? (Default is FALSE.)
#' @param json TRUE/FALSE. Should the function return a JSON-character string?
#' (Default is FALSE.) If TRUE output cannot be processed with the functions
#' from this package. Can be parsed using e.g. [jsonlite::fromJSON()].
#'
#' @returns an object (list) of class `idaifield_docs` if `raw = TRUE` and
#' `idaifield_resources` if `raw = FALSE` that contains all *docs*/*resources*
#' in the selected project except for the project configuration.
#' The `connection` and `projectname` are attached as attributes for
#' later use. (If `json = TRUE`, returns a character string in JSON-format.)
#'
#' @seealso
#' * For querying the database: [idf_query()],[idf_index_query()], [idf_json_query()]
#' * For filtering / selecting an `idaifield_docs`- or `idaifield_resources`-list: [idf_select_by()]
#' * For processing the list: [maybe_unnest_docs()], [simplify_idaifield()]
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
get_idaifield_docs <- function(connection, raw = TRUE, json = FALSE) {

  stop_if_not_idf_connection_settings(connection)

  # In preparation for getting the coordinates via JSON-API, we need to set
  # the digits option high enough to return a meaningful amount of digits for
  # each coordinate. I experienced problems with this before, which is why this
  # option is set here. on.exit() restores the old settings after the function
  # finished.
  old <- options(digits = 20)
  on.exit(options(old))


  client <- proj_idf_client(conn = connection,
                            include = "all")


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
    if (length(conf_ind) != 0) {
      idaifield_docs[[conf_ind]] <- NULL
    }

    idaifield_docs <- name_docs_list(idaifield_docs)
    idaifield_docs <- type_to_category(idaifield_docs)


    idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")
    attr(idaifield_docs, "connection") <- connection
    attr(idaifield_docs, "projectname") <- connection$project

    if (!raw) {
      idaifield_docs <- maybe_unnest_docs(idaifield_docs)
    }
  }


  return(idaifield_docs)
}
