#' @title Query *docs* from an iDAI.field Database Directly
#'
#' @description
#' This function can be used to gather *docs* from an iDAI.field / Field
#' Desktop Database according to the values of specific fields.
#'
#' @param connection A connection settings object as
#' returned by [connect_idaifield()]
#' @param field character. The resource field that should be selected for
#' (i.e. "category" for the category of resource (*Pottery*, *Brick*, *Layer*)).
#' @param value character. The value to be selected for in the specified
#' field (i.e. "*Brick*" when looking for resources of category *Brick*).
#' @param projectname (deprecated) The name of the project to be queried (overrides
#' the one listed in the connection-object).
#'
#' @returns An `idaifield_docs` list containing all *docs* that fit the query parameters.
#'
#'
#'
#' @seealso
#' * Alternative functions: [idf_index_query()], [idf_json_query()]
#'
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

  warn_for_project(project = projectname)

  if (is.null(connection$project)) {
    connection$project <- projectname
  }


  if (field == "type" | field == "category") {
    query <- paste0('{ "selector": { "$or": [  { "resource.type": "', value, '" },
    { "resource.category": "', value, '" }]}}')
  } else {
    query <- paste0('{ "selector": { "$or": [  { "resource.', field, '": "', value, '" },
    { "resource.', field, '": ["', value, '"] }]}}')
  }

  result <- idf_json_query(connection, query)

  return(result)
}


#' @title Query *docs* from an iDAI.field Database Based on an Index (uidlist)
#'
#' @description
#' This function can be used to gather *docs* from an iDAI.field / Field
#' Desktop Database according to the values of listed in an index as returned
#' by [get_field_index()] or [get_uid_list()].
#'
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param field character. The resource field that should be selected for
#' (options are limited to the column names of the uidlist).
#' @param value character. The value to be selected for in the specified field.
#' @param uidlist A data.frame as returned by [get_field_index()]
#' (or [get_uid_list()]).
#' @param projectname (deprecated) The name of the project to be queried (overrides
#' the one listed in the connection-object).
#'
#' @returns An `idaifield_docs` list
#'
#' @seealso
#' * Alternative functions: [idf_query()], [idf_json_query()]
#'
#'
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

  if (is.null(uidlist)) {
    stop("idf_index_query() needs an index of the database supplied to 'uidlist'. See `get_field_index()`")
  }

  if (!field %in% colnames(uidlist)) {
    stop("Supply a field that corresponds to the columns in the UID-List.")
  }

  warn_for_project(project = projectname)

  if (is.null(connection$project)) {
    connection$project <- projectname
  }

  doc_ids <- uidlist$UID[which(uidlist[, field] == value)]

  doc_ids <- paste('"', doc_ids, '"', collapse = ", ", sep = "")

  query <- paste('{ "selector": { "_id": { "$in": [', doc_ids, '] } }}',
                 sep = "")

  result <- idf_json_query(connection, query, projectname)

  return(result)
}




#' @title Query *docs* from an iDAI.field Database Based on a JSON-Query
#'
#' @description
#' This function can be used to gather *docs* from an iDAI.field / Field
#' Desktop Database using a JSON-Query as detailed by the
#' [CouchDB-API Docs](https://docs.couchdb.org/en/stable/api/database/find.html).
#'
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param query A valid JSON-query as detailed in the relevant section of the
#' [CouchDB-API](https://docs.couchdb.org/en/stable/api/database/find.html)
#' documentation.
#' @param projectname (deprecated) The name of the project to be queried (overrides
#' the one listed in the connection-object).
#'
#' @seealso
#' * Learn how to build the selector-query with the
#' [CouchDB-API](https://docs.couchdb.org/en/stable/api/database/find.html).
#' * Alternative functions: [idf_query()], [idf_index_query()]
#'
#' @returns An `idaifield_docs` list
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#'
#' # Get all documents that contain "Anna Allgemeinperson" as processor
#' query <- '{ "selector": { "resource.processor": ["Anna Allgemeinperson"] } }'
#' result <- idf_json_query(conn, query = query)
#'
#'
#' # Get all documents where hasRestoration is TRUE
#' query <- '{ "selector": { "resource.hasRestoration": true } }'
#' result <- idf_json_query(conn, query = query)
#'
#' # Get all documents where hasRestoration is TRUE
#' # but only the fields *identifier* and *hasRestoration*
#' query <- '{ "selector": { "resource.hasRestoration": true },
#' "fields": [ "resource.identifier", "resource.hasRestoration" ] }'
#' result <- idf_json_query(conn, query = query)
#'
#' }
idf_json_query <- function(connection, query, projectname = NULL) {
  if (!jsonlite::validate(query)) {
    stop("Could not validate JSON structure of query.")
  }

  warn_for_project(project = projectname)

  if (is.null(connection$project)) {
    connection$project <- projectname
  }

  proj_client <- proj_idf_client(connection,
                                 project = projectname,
                                 include = "query")


  response <- proj_client$post(body = query)
  response <- response_to_list(response)


  result <- lapply(response$docs,
                   function(x) list("id" = x$resource$id, "doc" = x))


  result <- name_docs_list(result)
  result <- type_to_category(result)

  projectname <- ifelse(is.null(projectname),
                        connection$project,
                        projectname)

  attr(result, "connection") <- connection
  attr(result, "projectname") <- projectname

  result <- structure(result, class = "idaifield_docs")

  return(result)
}


