#' Simplifies a single resource from the iDAI.field 2 / Field Desktop Database
#'
#' This function is a helper to `simplify_idaifield()`.
#'
#' @param resource One resource (element) from an idaifield_resources-list.
#' @param replace_uids logical. Should UIDs be automatically replaced with the
#' corresponding identifiers? (Defaults to TRUE).
#' @param uidlist A data.frame as returned by `get_uid_list()`. If replace_uids
#' is set to FALSE, there is no need to supply it.
#' @param keep_geometry logical. Should the geographical information be kept
#' or removed? (Defaults to TRUE).
#'
#' @return A single resource (element) for an idaifield_resource-list.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' simpler_resource <- simplify_single_resource(resource,
#' replace_uids = TRUE,
#' uidlist = uidlist,
#' keep_geometry = FALSE)
#' }
simplify_single_resource <- function(resource,
                                     replace_uids = TRUE,
                                     uidlist = NULL,
                                     keep_geometry = TRUE,
                                     fieldtypes = NULL,
                                     language = "all") {
  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from a 'idaifield_resources'-list.")
  }

  resource <- fix_relations(resource,
                            replace_uids = replace_uids,
                            uidlist = uidlist)

  # checks the value of the replace_uids argument, if it is TRUE,
  # calls the find_layer() function on the resource with resource, uidlist,
  # and NULL as arguments. The resulting value is assigned to the
  # liesWithinLayer variable and appended to the resource as a new field
  # called relation.liesWithinLayer.
  if (replace_uids) {
    liesWithinLayer <- find_layer(resource = resource,
                                  uidlist = uidlist,
                                  liesWithin = NULL)
    resource <- append(resource, list(relation.liesWithinLayer = liesWithinLayer))
  }

  # checks the value of the keep_geometry argument, which determines whether
  # to keep the geometry field in the resource or not. If keep_geometry is
  # FALSE, the function checks if the resource has a field called geometry and,
  # if so, removes it. If keep_geometry is TRUE, the reformat_geometry()-
  # function is called on the resource's geometry field and the resulting value
  # is assigned back to the geometry field of the resource.
  if (!keep_geometry) {
    names <- names(resource)
    has_geom <- any(grepl("geometry", names))
    if (has_geom) {
      resource$geometry <- NULL
    }
  } else {
    resource$geometry <- reformat_geometry(resource$geometry)
  }

  # Next, the function checks if the resource has a field called period, and
  # if so, assigns it to the period variable. If period is not NULL,
  # the function creates a new fixed_periods variable with two elements,
  # named period.start and period.end. If period has only one element,
  # both elements of fixed_periods are set to this value. If period has two
  # elements, the elements of fixed_periods are set to these values.
  # If period has more than two elements, a message is printed saying
  # "I did not see that coming." and the values of fixed_periods are not
  # modified. The fixed_periods variable is then appended to the resource.
  period <- resource$period
  if (!is.null(period)) {
    fixed_periods <- c(NA, NA)
    names(fixed_periods) <- c("period.start", "period.end")
    if (length(period) == 1) {
      fixed_periods[1:2] <- rep(unlist(period), 2)
    } else if (length(period) == 2) {
      fixed_periods[1:2] <- unlist(period)
    } else {
      message("I did not see that coming.")
    }
    resource <- append(resource, fixed_periods)
  }

  # The function then gets the names of all the fields in the resource,
  # and checks if any of them contain a colon (:). If so, the
  # remove_config_names() function is applied to the list of field names
  # to remove the portion after the colon. The resulting list of field names
  # is then assigned back to the resource. If the type field of the resource
  # contains a colon, the remove_config_names() function is also applied to
  # this field to remove the portion after the colon
  list_names <- names(resource)

  if (any(grepl(":", list_names))) {
    list_names <- remove_config_names(list_names)
    names(resource) <- list_names
  }

  if (any(grepl(":", resource$type))) {
    resource$type <- remove_config_names(resource$type)
  }


  # Next, the function gets all the field names in the resource that contain
  # the string "dimension", and assigns them to the dim_names variable.
  # If dim_names has at least one element, the function creates a new new_dims
  # list with a single element (1), and then iterates over each element of
  # dim_names. For each dim in dim_names, the idf_sepdim() function is called,
  # passing dim (the name of the field in question) as an additional argument.
  # The result is appended to the new_dims list. Once all elements of dim_names
  # have been processed, the new_dims list is converted to a flat list
  # (i.e., all sub-lists are removed) and the fields in resource with names
  # from dim_names are removed. The new_dims list is then appended
  # to the resource.
  dim_names <- list_names[grep("dimension", list_names)]

  if (length(dim_names) >= 1) {
    new_dims <- as.list(1)
    for (dim in dim_names) {
      new_dims <- append(new_dims, idf_sepdim(resource[[dim]], dim))
    }
    new_dims <- as.list(unlist(new_dims[-1]))


    resource[dim_names] <- NULL

    resource <- append(resource, new_dims)
  }

  if (language != "all") {
    resource <- lapply(resource, function(x) {
      names <- names(x)
      names <- grepl("^[a-z]{2}$", names)
      if (length(names) > 1) {
        gather_languages(list(x), language = language, silent = TRUE)
      } else {
        x
      }
    })
  }



  # Finally, the function checks if the fieldtypes argument is a matrix,
  # and if so, calls the convert_to_onehot() function on the resource with
  # fieldtypes as an additional argument. This converts the values in the
  # fields of resource to one-hot encoded vectors based on the
  # specified fieldtypes.
  if (is.matrix(fieldtypes)) {
    resource <- convert_to_onehot(resource = resource,
                                  fieldtypes = fieldtypes)
  }

  # Then, returns the modified resource.
  return(resource)
}

#' Simplify a list imported from an iDAI.field-Database
#'
#' @param idaifield_docs An "idaifield_docs" or "idaifield_resources"-list as
#' returned by `get_idaifield_docs()`.
#' @param replace_uids logical. Should UIDs be automatically replaced with the
#' corresponding identifiers? (Defaults to TRUE).
#' @param uidlist If NULL (default) the list of UIDs and identifiers is
#' automatically generated within this function. This only makes sense if
#' the list handed to `simplify_idaifield()` had not been selected yet. If it
#' has been, you should supply a data.frame as returned by `get_uid_list()`.
#' @param keep_geometry logical. Should the geographical information be kept
#' or removed? (Defaults to TRUE).
#'
#' @return a simplified "idaifield_resources"-list
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest")
#'
#' simpler_idaifield <- simplify_idaifield(idaifield_docs)
#' }
simplify_idaifield <- function(idaifield_docs,
                               keep_geometry = TRUE,
                               replace_uids = TRUE,
                               uidlist = NULL,
                               language = "all") {


  check <- check_if_idaifield(idaifield_docs)
  if (check["idaifield_simple"] == TRUE) {
    return(idaifield_docs)
  }

  if (is.null(uidlist)) {
    uidlist <- get_uid_list(idaifield_docs)
  }


  if (!is.null(attr(idaifield_docs, "connection"))) {
    connection <- attr(idaifield_docs, "connection")
    projectname <- attr(idaifield_docs, "projectname")
    config <- get_configuration(connection = connection,
                                projectname = projectname)
  }

  if (is.na(config[1])) {
    fieldtypes <- NA
  } else {
    fieldtypes <- get_field_inputtypes(config, inputType = "all")
    languages <- unlist(config$projectLanguages)
    if (language != "all") {
      if (language %in% languages) {
        message(paste("Keeping input values of selected language (",
                      language, ") where possible.",
                      sep = ""))
      } else {
        message(paste("Selected language (",
                      language, ") not available.",
                      sep = ""))
      }
    } else {
      message("Keeping all languages for input fields.")
    }
  }
  idaifield_docs <- check_and_unnest(idaifield_docs)

  idaifield_simple <- lapply(idaifield_docs, function(x)
    simplify_single_resource(
      x,
      replace_uids = replace_uids,
      uidlist = uidlist,
      keep_geometry = keep_geometry,
      fieldtypes = fieldtypes,
      language = language
    )
  )

  idaifield_simple <- structure(idaifield_simple, class = "idaifield_simple")
  attr(idaifield_simple, "connection") <- connection
  attr(idaifield_simple, "projectname") <- projectname

  return(idaifield_simple)
}
