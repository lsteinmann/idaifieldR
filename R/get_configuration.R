#' get_configuration: returns configuration list
#'
#' This function retrieves the project configuration (if existent) from an
#' iDAI.field project.
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project in the Field Client that one
#' wishes to load.
#'
#' @return a list containing the project configuration; NA if the configuration
#' could not be found
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' config <- get_configuration(connection = conn,
#' projectname = "rtest")
#' }
get_configuration <- function(connection, projectname = "rtest") {
  query <- '{ "selector": { "resource.identifier": "Configuration"}}'
  tryCatch({
    config <- sofa::db_query(cushion = connection,
                             dbname = projectname,
                             query = query)$docs[[1]]$resource
    return(config)
  },
  error = function(e) {
    message("Error: No Configuration found!")
    return(NA)
  })
}


#' get_field_inputtypes: returns a matrix of inputTypes
#'
#' This function retrieves a matrix containing the inputTypes of all
#' fields and their corresponding inputTypes
#' from a project configuration (if existent) of an
#' iDAI.field project.
#'
#'
#' @param config A configuration list as returned by `get_configuration()`
#' @param inputType if specified, matrix is filtered to return only the
#' specified type
#'
#' @return a matrix of fields with the given inputType
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' config <- get_configuration(connection = conn,
#' projectname = "rtest")
#' checkboxes <- get_field_inputtypes(config, inputType = "checkboxes")
#' }
get_field_inputtypes <- function(config, inputType = "all") {
  fields <- lapply(config$forms, FUN = function(x) (unlist(x$fields)))
  fields <- unlist(fields)
  names(fields) <- gsub(".inputType", "",names(fields))
  names(fields) <- gsub(":default", "",names(fields))
  if (inputType %in% unique(fields)) {
    fields <- fields[fields == inputType]
  }
  fields_mat <- matrix(nrow = length(fields), ncol = 3)
  colnames(fields_mat) <- c("type", "field", "inputType")
  fields_mat[,1] <- gsub("\\..*", "", names(fields))
  fields_mat[,2] <- gsub(".*\\.", "", names(fields))
  fields_mat[,3] <- unname(fields)
  return(fields_mat)
}

