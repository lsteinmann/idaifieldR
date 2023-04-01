#' Query resources from an iDAI.field database directly
#'
#' @param connection A connection settings object as
#' returned by `connect_idaifield()`
#' @param field character. The resource field that should be selected
#' for (i.e. "category" for the category of resource (Pottery, Brick, Layer)).
#' @param value character. The value to be selected for in the specified
#' field (i.e. "Brick" when looking for resources of category "Brick").
#' @param projectname The name of the project to be queried (overrides
#' the one listed in the connection-object).
#'
#' @return An 'idaifield_docs' list
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' idf_query(conn, field = "category", value = "Brick")
#' }
idf_query <- function(connection,
                      field = "category",
                      value = "Pottery",
                      projectname = NULL) {

  if (field == "type") {
    query <- paste0('{ "selector": { "$or": [  { "resource.type": "', value, '" },
    { "resource.category": "', value, '" }]}}')
  } else {
    query <- paste0('{ "selector": { "resource.',
                    field, '": "', value, '"}}')
  }

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
#' @param field character. The resource field that should be selected for
#' (options are limited to the columns names of the uidlist).
#' @param value character. The value to be selected for in the specified field.
#' @param uidlist A data.frame as returned by `get_field_index()`
#' (or `get_uid_list()`)
#' @param projectname The name of the project to be queried (overrides
#' the one listed in the connection-object).
#'
#' @return An 'idaifield_docs' list
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' uidlist <- get_field_index(conn)
#' idf_index_query(conn,
#'                 field = "category",
#'                 value = "Brick",
#'                 uidlist = uidlist)
#' }
#'
idf_index_query <- function(connection,
                            field = "category",
                            value = "Brick",
                            uidlist = NULL,
                            projectname = NULL) {


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
