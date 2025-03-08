#' Get the Custom Project Configuration as Provided by the Field API
#'
#' This function retrieves the complete project configuration (if existent)
#' from an [iDAI.field](https://github.com/dainst/idai-field) project via
#' Field's configuration endpoint. The list will only contain the complete
#' configuration as used in the project, including custom and *fields*,
#' *valuelists* and *translations*.
#'
#' @param connection A connection object as returned
#' by [connect_idaifield()]
#' @param projectname (deprecated) The name of the project in the Field Client that one
#' wishes to load. Will overwrite the project argument that was set
#' in [connect_idaifield()].
#'
#' @returns A list containing the project configuration; `NA` if the configuration
#' could not be found or the connection failed.
#'
#' @seealso
#' * (Wont work currently) Get the inputTypes from a Configuration: [get_field_inputtypes()]
#' * (Wont work currently) This function is used by: [simplify_idaifield()].
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo", project = "rtest")
#' config <- get_configuration(connection = conn)
#' }
get_configuration <- function(connection, projectname = NULL) {

  warn_for_project(project = projectname)

  if (is.null(connection$project)) {
    connection$project <- projectname
  }

  url <- gsub("3001", "3000", connection$settings$base_url)

  proj_conn <- crul::HttpClient$new(url = paste0(url, "/configuration/", connection$project),
                                    opts = connection$settings$auth,
                                    headers = connection$settings$headers)

  response <- response_to_list(proj_conn$get())

  if ("categories" %in% names(response)) {
    config <- name_all_nested_lists(response)
    return(config)
  } else if ("reason" %in% names(response)) {
    warning(paste0("get_configuration() returning NA: ", response$reason))
    return(NA)
  } else {
    warning("get_configuration() returning NA: Something unexpected happened.")
    return(NA)
  }

}


#' Produce a Matrix of Field *inputTypes* from the Custom Project Configuration
#'
#' This function retrieves a matrix containing the *inputTypes* of all
#' custom fields from a project configuration of an
#' [iDAI.field](https://github.com/dainst/idai-field) project.
#'
#'
#' @param config A configuration list as returned
#' by [get_configuration()]
#' @param inputType If specified, matrix is filtered to return only the
#' specified type.
#' @param remove_config_names TRUE/FALSE: Should the name of the project be
#' removed from field names of the configuration? (Default is TRUE.)
#' (Should e.g.: *test:amount* be renamed to *amount*,
#' see [remove_config_names()].)
#' @param silent TRUE/FALSE, default: FALSE. Should messages be suppressed?
#'
#' @returns A matrix of fields (with the given *inputType*).
#'
#' @seealso
#' * [get_configuration()], [convert_to_onehot()]
#' * This function is used by: [simplify_idaifield()].
#'
#'
#'
#'
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
get_field_inputtypes <- function(config, inputType = "all",
                                 remove_config_names = TRUE,
                                 silent = FALSE) {
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
  if (remove_config_names == TRUE) {
    tmp <- remove_config_names(fields_mat[, 1], silent = silent)
    attrib_dupl <- attributes(tmp)$duplicate_names
    fields_mat[, 1] <- tmp
    tmp <- remove_config_names(fields_mat[, 2], silent = silent)
    attrib_dupl <- list(categories = attrib_dupl, fields  = attributes(tmp)$duplicate_names)
    fields_mat[, 2] <- tmp
  } else {
    attrib_dupl <- NA
  }
  fields_mat[, 3] <- unname(fields)
  attributes(fields_mat)$duplicate_names <- attrib_dupl
  return(fields_mat)
}
