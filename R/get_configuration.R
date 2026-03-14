#' Get the Custom Project Configuration as Provided by the Field API
#'
#' This function retrieves the complete project configuration (if existent)
#' from an [iDAI.field](https://github.com/dainst/idai-field) project via
#' Field's configuration endpoint. The list will only contain the complete
#' configuration as used in the project, including custom and *fields*,
#' *valuelists* and *translations*.
#'
#' @param connection A connection object as returned by [connect_idaifield()]
#'
#' @returns A list containing the project configuration; `NA` if the configuration
#' could not be found or the connection failed.
#'
#' @seealso
#' * Get the inputTypes from a Configuration: [extract_inputtypes()]
#' * This function is used by: [simplify_idaifield()].
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(
#'   serverip = "localhost", pwd = "hallo", project = "rtest"
#' )
#' config <- get_configuration(connection = conn)
#' }
get_configuration <- function(connection) {
  stop_if_not_idf_connection_settings(connection)

  url <- paste0("http://",
                connection$params$serverip,
                ":3000/configuration/",
                connection$project)

  proj_conn <- crul::HttpClient$new(url = url,
                                    opts = connection$settings$auth,
                                    headers = connection$settings$headers)

  response <- response_to_list(proj_conn$get())

  if ("categories" %in% names(response)) {
    config <- name_all_nested_lists(response)
    config <- structure(config, class = "idaifield_config")
    attr(config, "connection") <- connection
    attr(config, "projectname") <- connection$project
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
#' @param config An `idaifield_config` as returned by [get_configuration()]
#'
#' @returns A data.frame with four columns: category: each category, its parent
#' (or itself if it is a supercategory),
#'
#' @seealso
#' * [get_configuration()], [convert_to_onehot()]
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo",
#'                           project = "rtest")
#' config <- get_configuration(connection = conn)
#' input_type_df <- get_field_inputtypes(config = config)
#' }
get_field_inputtypes <- function(config = NULL) {
  if (!inherits(config, "idaifield_config")) {
    stop("'config' must be an 'idaifield_config' object as returned by get_configuration().")
  }

  extracted_list <- extract_inputtypes(config)

  if (is.null(extracted_list) || length(extracted_list) == 0) {
    stop("Extraction of 'inputType's failed.")
  }

  result <- do.call(rbind, extracted_list)
  result <- apply(result, 2, as.character)
  result[result == "NULL"] <- NA

  return(as.data.frame(result))
}


#' Extracts a List of Input Types from the Project Configuration
#'
#' Internal helper to [get_field_inputtypes()]
#'
#' @param nested_list A configuration list as returned
#' by [get_configuration()]
#' @param parent_name Used for recursive behaviour
#' @param category_name Used for recursive behaviour
#'
#' @keywords internal
#'
#' @returns A list
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "localhost",
#'                           pwd = "hallo",
#'                           project = "rtest")
#' config <- get_configuration(connection = conn)
#' input_types <- extract_inputtypes(config)
#' }
extract_inputtypes <- function(nested_list,
                               parent_name = NULL,
                               category_name = NULL) {
  results <- list()

  # This is a hard to maintain and understand mess. I currently have no idea
  # how to do this better without e.g. importing `purrr`, and I wanted to
  # keep imports as minimal as possible.

  # Check if the current list has an 'item' (i.e., we are inside a category).
  if ("item" %in% names(nested_list)) {
    # If we have no category_name yet, this is the first level (supercategory),
    # so the category is whatever parent_name was set to by the caller.
    category_name <- if (is.null(category_name)) parent_name else category_name

    # If 'groups' exists, extract its sublists and collect fields.
    if ("groups" %in% names(nested_list$item)) {
      for (group_name in names(nested_list$item$groups)) {
        group <- nested_list$item$groups[[group_name]]

        if ("fields" %in% names(group)) {
          for (field_name in names(group$fields)) {
            input_type <- group$fields[[field_name]]$inputType

            results <- append(results, list(
              list(
                category  = category_name,
                parent    = if (is.null(parent_name)) category_name else parent_name,
                fieldname = field_name,
                inputType = input_type
              )
            ))
          }
        }
      }
    }
  }

  # Recurse into "categories" (top level) and "trees" (subcategory level).
  for (key in names(nested_list)) {
    if (is.list(nested_list[[key]]) && key %in% c("categories", "trees")) {
      for (sub_key in names(nested_list[[key]])) {
        sub_list <- nested_list[[key]][[sub_key]]

        if (is.null(parent_name)) {
          # First level: sub_key is a supercategory name, becomes parent_name.
          results <- append(results,
                            extract_inputtypes(sub_list,
                                               parent_name = sub_key))
        } else {
          # Second level: parent_name is already the supercategory; sub_key is
          # the subcategory name, becomes category_name.
          results <- append(results,
                            extract_inputtypes(sub_list,
                                               parent_name   = parent_name,
                                               category_name = sub_key))
        }
      }
    }
  }

  if (length(results) > 0) {
    return(results)
  }

  return(NULL)
}
