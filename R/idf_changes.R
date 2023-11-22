#' Get a vector of UUIDs or identifiers of the last n changed resources
#'
#' Retrieves the names/identifiers or UUIDs of the most recently changed
#' resources in the database. If an index as returned by [get_field_index()]
#' or [get_uid_list()] is returned, the UUIDs are replaced by identifiers.
#' If not, the UUIDs are returned directly and can be used for querying e.g.
#' with
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param index A data.frame as returned by [get_field_index()]
#' (or [get_uid_list()]).
#' @param n numeric. Maximum number of last changed resources to get.
#'
#' @return A vector of `UUID`s or `identifier`s of the most
#' recently changed `n` resources.
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(pwd = "hallo", project = "rtest")
#' index <- get_field_index(connection)
#' last_changed <- idf_last_changed(
#'     connection = connection,
#'     index = index,
#'     n = 100
#' )
#' }
idf_last_changed <- function(connection,
                             index = NULL,
                             n = 100) {

  if (is.null(connection$project)) {
    stop("Please supply a project to `connect_idaifield()`.")
  }

  client <- proj_idf_client(connection,
                            include = "changes")

  params <- list("include_docs" = "false",
                 "descending" = "true")
  if(n != Inf && n != "all") {
    stopifnot(is.numeric(n))
    params <- append(params, list("limit" = n))
  }

  response <- client$post(query = params)
  response <- response_to_list(response)

  response <- lapply(response$results, function(x) {
    x$id
  })

  response <- unlist(response)

  if (!is.null(index)) {
    uidcols <- c("UID", "UUID", "id")
    if (any(uidcols %in% colnames(index)) && "identifier" %in% colnames(index)) {
      response <- replace_uid(response, index)
    } else {
      warning(paste0("`index` is not a data.frame as returned by ",
                     "`get_field_index()` or `get_uid_list()`. ",
                     "UUIDs have not been replaced."))
    }
  }

  return(response)
}




#' See when and by whom selected resources have been created or modified
#'
#'
#' @param connection A connection object as returned by [connect_idaifield()]
#' @param ids A vector of either **identifier**s or **UUID**s of resources for which
#' the changes should be returned.
#'
#' @return A data.frame in which each row corresponds to a change made to the
#' resource named in the *identifier* column at the time stated in the *date*
#' column by the user stated in the *user* column. In the *action* column,
#' the value can either be *created* referring to the date of first creation
#' of the resource, or *modified* referring to the date when it was changed.
#'
#' @seealso
#' * [idf_last_changed()]
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(pwd = "hallo", project = "rtest")
#' index <- get_field_index(connection)
#' last_changed <- idf_last_changed(
#'     connection = connection,
#'     index = index,
#'     n = 100
#' )
#' changes_df <- idf_get_changes(connection, ids = last_changed)
#' }
idf_get_changes <- function(connection, ids) {

  uuid_check <- check_if_uid(ids)

  if (any(ids == "project")) {
    uuid_check[which(ids == "project")] <- TRUE
  }
  if (any(ids == "configuration")) {
    uuid_check[which(ids == "configuration")] <- TRUE
  }

  doc_ids <- paste('"', ids, '"', collapse = ", ", sep = "")

  fields <- c("resource.identifier",
              "created",
              "modified")

  if (all(uuid_check)) {
    selector <- paste('{ "_id": { "$in": [', doc_ids, '] } }')
  } else {
    selector <- paste('{ "resource.identifier": { "$in": [',
                      doc_ids, '] } }')
  }

  query <- paste('{ "selector": ', selector, ',
   "fields": [', paste0('"', fields, '"', collapse = ", "), '] }')


  if (is.null(connection$project)) {
    check_conn_for_project(project = NULL, fail = TRUE)
  }

  result <- idf_json_query(connection, query)

  if (length(result) == 0) {
    warning("No resources found.")
    result <- as.data.frame(matrix(nrow = 0, ncol = 4))
    colnames(result) <- c("identifier", "user", "date", "action")
    return(result)
  }

  result <- lapply(result, function(x) {
    list(created = x$doc$created,
         modified = x$doc$modified,
         identifier = x$doc$resource$identifier)
  })

  result <- lapply(result, function(x) {
    new <- c(identifier = x$identifier,
             user = x$created$user,
             date = x$created$date,
             action = "created")
    new_mod <- lapply(x$modified, function(y) {
      id <- x$identifier
      new_y <- c(identifier = id,
                 user = y$user,
                 date = y$date,
                 action = "modified")
      new_y
    })
    new_mod <- do.call(rbind, new_mod)
    new <- rbind(new, new_mod)
    return(new)
  })
  result <- as.data.frame(do.call(rbind, result))
  rownames(result) <- NULL

  result$date <- as.POSIXct(result$date, format="%Y-%m-%dT%H:%M:%S")

  return(result)
}
