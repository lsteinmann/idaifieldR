#' Get the custom project configuration as stored in the project database
#'
#' This function retrieves the project configuration (if existent) from an
#' iDAI.field project. The list will only contain fields and valuelists
#' that have been edited in the project configuration editor in iDAI.field 3
#' (Field Desktop) and does not encompass fields, valuelists and translation
#' added before the update to iDAI.field 3.
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param projectname The name of the project in the Field Client that one
#' wishes to load. Will overwrite the project argument that was set
#' in `connect_idaifield()`.
#'
#' @return a list containing the project configuration; NA if the configuration
#' could not be found or the connection failed.
#'
#' @seealso \code{\link{get_field_inputtypes}},
#' \code{\link{get_language_lookup}}, \code{\link{download_language_list}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo", project = "rtest")
#' config <- get_configuration(connection = conn,
#' projectname = "rtest")
#' }
get_configuration <- function(connection, projectname = NULL) {

  query <- '{ "selector": { "resource.identifier": "Configuration"}}'

  proj_client <- proj_idf_client(connection,
                                 project = projectname,
                                 include = "query")

  response <- proj_client$post(body = query)
  response <- response_to_list(response)

  if (length(response$docs) == 0) {
    warning("Error in get_configuration(), returning NA: Project has no configuration!")
    return(NA)
  } else {
    config <- find_resource(response)
    config <- try(config[[1]], silent = TRUE)
    return(config)
  }

}


#' Produce a matrix of field inputTypes from the custom project configuration
#'
#' This function retrieves a matrix containing the inputTypes of all
#' custom fields and their corresponding inputTypes from a project
#' configuration (if existent) of an iDAI.field project.
#'
#'
#' @param config A configuration list as returned by `get_configuration()`
#' @param inputType if specified, matrix is filtered to return only the
#' specified type
#'
#' @return A matrix of fields with the given inputType
#'
#' @seealso \code{\link{get_configuration}}, \code{\link{convert_to_onehot}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#'                           pwd = "hallo",
#'                           project = "rtest")
#' config <- get_configuration(connection = conn)
#' checkboxes <- get_field_inputtypes(config, inputType = "checkboxes")
#' }
get_field_inputtypes <- function(config, inputType = "all") {
  fields <- lapply(config$forms, FUN = function(x) (unlist(x$fields)))
  fields <- unlist(fields)
  if (is.null(fields)) {
    warning("No custom fields found in configuration!")
  } else {
    names(fields) <- gsub(".inputType", "", names(fields))
    names(fields) <- gsub(":default", "", names(fields))
    if (inputType %in% unique(fields)) {
      fields <- fields[fields == inputType]
    }
  }
  fields_mat <- matrix(nrow = length(fields), ncol = 3)
  colnames(fields_mat) <- c("category", "field", "inputType")
  fields_mat[, 1] <- gsub("\\..*", "", names(fields))
  fields_mat[, 2] <- gsub(".*\\.", "", names(fields))
  fields_mat[, 1] <- remove_config_names(fields_mat[, 1])
  fields_mat[, 2] <- remove_config_names(fields_mat[, 2])
  fields_mat[, 3] <- unname(fields)
  return(fields_mat)
}
