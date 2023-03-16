#' idf_query
#'
#' Queries resources from an iDAI.field database that is currently running
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project to be queried.
#' @param field The resource field that should be selected for (i.e. "type" for
#' the type of resource (Pottery, Brick, Layer)).
#' @param value The value to be selected for in the specified field (i.e.
#' "Brick" when looking for resourced of type "Brick").
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

  fail <- idf_ping(connection)
  if(is.character(fail)) {
    stop(fail)
  }

  query <- paste('{ "selector": { "resource.',
                 field, '": "', value, '"}}', sep = "")

  result <- sofa::db_query(cushion = connection,
                           dbname = projectname,
                           query = query)


  config <- get_configuration(connection, projectname)

  result <- lapply(result$docs,
                   function(x) list("id" = x$resource$id, "doc" = x))

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname
  attr(result, "config") <- get_configuration(connection, projectname)
  result <- structure(result, class = "idaifield_docs")

  return(result)
}


#' idf_index_query
#'
#' Queries resources from an iDAI.field database that is currently running
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project to be queried.
#' @param field The resource field that should be selected for (options are
#' limited to the columns names of the uidlist).
#' @param value The value to be selected for in the specified field.
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
idf_index_query <- function(connection, projectname = "NULL",
                      field = "type",
                      value = "Brick",
                      uidlist = NULL) {

  fail <- idf_ping(connection)
  if(is.character(fail)) {
    stop(fail)
  }

  if (!field %in% colnames(uidlist)) {
    stop("Supply a field that corresponds to the columns in the UID-List.")
  }

  doc_ids <- uidlist$UID[which(uidlist[, field] == value)]

  doc_ids <- paste('"', doc_ids, '"', collapse = ", ", sep = "")

  query <- paste('{ "selector": { "_id": { "$in": [', doc_ids, '] } }}',
                 sep = "")

  result <- sofa::db_query(cushion = connection,
                           dbname = projectname,
                           query = query)

  result <- lapply(result$docs,
                   function(x) list("id" = x$resource$id, "doc" = x))

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname
  attr(result, "config") <- get_configuration(connection, projectname)

  result <- structure(result, class = "idaifield_docs")

  return(result)
}
