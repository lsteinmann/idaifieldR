#' Query resources from an iDAI.field database directly
#'
#' @param connection A connection settings object as
#' returned by `connect_idaifield()`
#' @param projectname The name of the project to be queried (overrides
#' the one listed in the connection-object).
#' @param field character. The resource field that should be selected
#' for (i.e. "type" for the type of resource (Pottery, Brick, Layer)).
#' @param value character. The value to be selected for in the specified
#' field (i.e. "Brick" when looking for resourced of type "Brick").
#'
#' @return An 'idaifield_docs' list
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo")
#' idf_query(conn, projectname = "rtest", field = "type", value = "Brick")
#' }
idf_query <- function(connection,
                      projectname = "NULL",
                      field = "type",
                      value = "Brick") {

  query <- paste('{ "selector": { "resource.',
                 field, '": "', value, '"}}', sep = "")

  proj_client <- proj_idf_client(connection,
                                 project = projectname,
                                 include = "query")

  response <- proj_client$post(body = query)
  response <- response$parse("UTF-8")
  response <- jsonlite::fromJSON(response, FALSE)


  config <- get_configuration(connection, projectname)

  result <- lapply(response$docs,
                   function(x) list("id" = x$resource$id, "doc" = x))

  new_names <- lapply(result, function(x)
    x$doc$resource$identifier)
  new_names <- unlist(new_names)
  names(result) <- new_names

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname
  attr(result, "config") <- suppressMessages(get_configuration(connection, projectname))
  result <- structure(result, class = "idaifield_docs")

  return(result)
}


#' Query resources from an iDAI.field database based on the uidlist
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project to be queried (overrides
#' the one listed in the connection-object).
#' @param field character. The resource field that should be selected for
#' (options are limited to the columns names of the uidlist).
#' @param value character. The value to be selected for in the specified field.
#' @param uidlist A data.frame as returned by `get_uid_list()`.
#'
#' @return An 'idaifield_docs' list
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo")
#' uidlist <- get_uid_list(conn, projectname = "rtest")
#' idf_index_query(conn,
#' projectname = "rtest",
#' field = "type",
#' value = "Brick",
#' uidlist = uidlist)
#' }
#'
idf_index_query <- function(connection,
                            projectname = "NULL",
                            field = "type",
                            value = "Brick",
                            uidlist = NULL) {


  if (!field %in% colnames(uidlist)) {
    stop("Supply a field that corresponds to the columns in the UID-List.")
  }

  doc_ids <- uidlist$UID[which(uidlist[, field] == value)]

  doc_ids <- paste('"', doc_ids, '"', collapse = ", ", sep = "")

  query <- paste('{ "selector": { "_id": { "$in": [', doc_ids, '] } }}',
                 sep = "")

  proj_client <- proj_idf_client(connection,
                                 project = projectname,
                                 include = "query")

  response <- proj_client$post(body = query)
  response <- response$parse("UTF-8")
  response <- jsonlite::fromJSON(response, FALSE)

  result <- lapply(response$docs,
                   function(x) list("id" = x$resource$id, "doc" = x))


  new_names <- lapply(result, function(x)
    x$doc$resource$identifier)
  new_names <- unlist(new_names)
  names(result) <- new_names

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname
  attr(result, "config") <- get_configuration(connection, projectname)

  result <- structure(result, class = "idaifield_docs")

  return(result)
}
