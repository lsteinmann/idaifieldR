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
#' @param uidlist A data.frame as returned by `get_uid_list()`.
#' @param keep_geometry logical. Should the geographical information be kept
#' or removed? (Defaults to TRUE).
#'
#' @return A simplified list with all matching resources.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' idf_query(connection, projectname = "rtest", field = "type", value = "Brick")
#' }
#'
idf_query <- function(connection, projectname,
                      field = "type",
                      value = "Brick",
                      uidlist = NULL,
                      keep_geometry = TRUE) {

  query <- paste('{ "selector": { "resource.',
                 field, '": "', value, '"}}', sep = "")

  result <- sofa::db_query(cushion = connection,
                           dbname = projectname,
                           query = query)


  config <- get_configuration(connection, projectname)

  result <- lapply(result[[1]],
                   function(x) x$resource)
  result <- lapply(result,
                   function(x) simplify_single_resource(x,
                                              uidlist = uidlist,
                                              replace_uids = TRUE,
                                              keep_geometry = keep_geometry,
                                              config = config))

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname
  result <- structure(result, class = "idaifield_resources")

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
#' @param keep_geometry logical. Should the geographical information be kept
#' or removed? (Defaults to TRUE).
#'
#' @return A simplified list with all matching docs.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' idf_index_query(connection,
#' projectname = "milet",
#' field = "type",
#' value = "Brick")
#' }
#'
idf_index_query <- function(connection, projectname,
                      field = "type",
                      value = "Brick",
                      keep_geometry = TRUE,
                      uidlist = NULL) {

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


  config <- get_configuration(connection, projectname)

  result <- simplify_idaifield(idaifield_docs = result,
                               keep_geometry = keep_geometry,
                               replace_uids = TRUE,
                               uidlist = uidlist)

  return(result)
}
