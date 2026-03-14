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

  url <- gsub("3001", "3000", connection$settings$base_url)

  proj_conn <- crul::HttpClient$new(url = paste0(url, "/configuration/",
                                                 connection$project),
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
    stop("")
  }
  extracted_list <- extract_inputtypes(config)
  mat <- do.call(rbind, extracted_list)
  mat <- apply(mat, 2, as.character)

  return(as.data.frame(mat))
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
  results <- list()  # Store results

  # I am terribly sorry for this mess. It is horrible. It works, but it hurts.

  # Check if the current list has an 'item' (i.e., a category)
  if ("item" %in% names(nested_list)) {
    # if we got not category_name, it means that this is the first try
    # which means our category is what was stored as "parent_name" on
    # the first level of the config (main categories)
    category_name <- ifelse(is.null(category_name), parent_name, category_name)

    # If 'groups' exists, extract its sublists
    if ("groups" %in% names(nested_list$item)) {
      for (group_name in names(nested_list$item$groups)) {
        group <- nested_list$item$groups[[group_name]]

        # If 'fields' exists in this group, extract field names and inputType
        if ("fields" %in% names(group)) {
          for (field_name in names(group$fields)) {
            input_type <- group$fields[[field_name]]$inputType

            # Store the extracted row
            results <- append(results, list(
              list(
                category = category_name,
                parent = ifelse(is.null(parent_name), category_name, parent_name),
                fieldname = field_name,
                inputType = input_type
              )
            ))
          }
        }
      }
    }
  }

  # No item or groups or fields in names(nested_list)
  # Recurse into "categories" and "trees"'
  for (key in names(nested_list)) {
    if (is.list(nested_list[[key]]) && key %in% c("categories", "trees")) {
      for (sub_key in names(nested_list[[key]])) {
        sub_list <- nested_list[[key]][[sub_key]]
        # if we did not get a parent_name yet, it means we are on the
        # first level of the config with the main categories, thus we set the
        # parent name:
        if (is.null(parent_name)) {
          results <- append(results,
                            extract_inputtypes(sub_list,
                                               parent_name = sub_key))
        } else {
          # otherwise it means we are now at the second
          # level (i.e. sub-categories); so we pass the previous parent_name
          # whill will be the main category, but also pass this
          # categories name, which is the sub_key now:
          results <- append(results,
                            extract_inputtypes(sub_list,
                                               parent_name = parent_name,
                                               category_name = sub_key))
        }
      }
    }
  }

  if (length(results) > 0) {
    return(results)
  }
}

