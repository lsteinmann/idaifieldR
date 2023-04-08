#' Simplifies a single resource from the iDAI.field 2 / Field Desktop Database
#'
#' This function is a helper to `simplify_idaifield()`.
#'
#' @param resource One resource (element) from an idaifield_resources-list.
#' @param replace_uids see `?simplify_idaifield()`
#' @param uidlist see `?simplify_idaifield()`
#' @param keep_geometry see `?simplify_idaifield()`
#' @param language see `?simplify_idaifield()`
#' @param spread_fields see `?simplify_idaifield()`
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
                                     language = "all",
                                     spread_fields = TRUE,
                                     use_exact_dates = FALSE) {
  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from a 'idaifield_resources'-list.")
  }

  if (is.null(resource$category)) {
    resource$category <- resource$type
    resource$type <- NULL
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
    lw <- list(liesWithin = resource$relation.liesWithin)
    liesWithinLayer <- find_layer(resource = lw,
                                  uidlist = uidlist,
                                  liesWithin = NULL)
    resource <- append(resource,
                       list(relation.liesWithinLayer = liesWithinLayer))
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
      # this actually never ever happens ;)
      message(paste("Somehow, resource", id,
                    "has more than two values for field 'period'.",
                    "Using first two."))
      fixed_periods[1:2] <- unlist(period)[1:2]
    }
    resource <- append(resource, fixed_periods)
  }

  dating <- resource[["dating", exact = TRUE]]
  if (!is.null(dating)) {
    dating <- fix_dating(dating, use_exact_dates = use_exact_dates)
    resource$dating <- NULL
    resource <- append(resource, dating)
  }

  # The function then gets the names of all the fields in the resource,
  # and checks if any of them contain a colon (:). If so, the
  # remove_config_names() function is applied to the list of field names
  # to remove the portion after the colon. The resulting list of field names
  # is then assigned back to the resource. If the category field of the resource
  # contains a colon, the remove_config_names() function is also applied to
  # this field to remove the portion after the colon
  list_names <- names(resource)

  if (any(grepl(":", list_names))) {
    list_names <- remove_config_names(list_names)
    names(resource) <- list_names
  }

  if (any(grepl(":", resource$category))) {
    resource$category <- remove_config_names(resource$category)
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
      # if there actually are different languages in the resource,
      # try to process them
      pat <- c("^[a-z]{2}$", "unspecifiedLanguage")
      names <- names(x)
      names <- grepl(paste0(pat, collapse = "|"), names)
      if (all(names)) {
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
  if (spread_fields & is.matrix(fieldtypes)) {
    resource <- convert_to_onehot(resource = resource,
                                  fieldtypes = fieldtypes)
  }

  # Then, returns the modified resource.
  return(resource)
}

#' Simplify a list imported from an iDAI.field-Database
#'
#' The function will take a list as returned by `get_idaifield_docs()` and
#' process it to make the list more useable. It will unnest a view lists,
#' including the dimension-lists and the period-list to provide single values
#' for later processing with `idaifield_as_matrix()`. If a connection to the
#' database can be established, the function will get the relevant project
#' configuration and convert custom checkboxes-fields to multiple lists,
#' each for every value from the respective valuelist, to make them more
#' accessible during the conversion with `idaifield_as_matrix()`. It will also
#' remove the custom configuration field names that are in use since
#' iDAI.field 3 / Field Desktop and consist of "projectname:fieldName". Only
#' the "projectname:"-part will be removed.
#'
#' Please note: The function will need an Index (i.e. uidlist as provided
#' by `get_uid_list()`) of the complete project database to correctly replace
#' the UUIDs with their corresponding identifiers! Especially if a selected
#' list is passed to `simplify_idaifield()`, you need to supply the uidlist
#' of the complete project database as well.
#'
#' Formatting of various lists: Dimension measurements as well as dating are
#' reformatted and might produce unexpected results.
#' For the dating, all begin and end values are evaluated and for each resource,
#' the minimum value from "begin" and maximum value from "end" is selected.
#' For the dimension-fields, if a ranged measurement was selected, a mean
#' will be returned.
#'
#' @param idaifield_docs An "idaifield_docs" or "idaifield_resources"-list as
#' returned by `get_idaifield_docs()` or `idf_query()` and `idf_index_query()`.
#' @param replace_uids logical. Should UUIDs be automatically replaced with the
#' corresponding identifiers? (Defaults to TRUE).
#' @param uidlist If NULL (default) the list of UUIDs and identifiers is
#' automatically generated within this function. This only makes sense if
#' the list handed to `simplify_idaifield()` had not been selected yet. If it
#' has been, you should supply a data.frame as returned by `get_uid_list()`.
#' @param keep_geometry logical. (Defaults to FALSE) Should the geographical
#' information be kept or removed?
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the multi-language input fields, defaults to keeping all
#' languages as sub-lists ("all").
#' @param spread_fields logical. (Defaults to TRUE) Should checkbox-fields be
#' spread across multiple lists to facilitate boolean-columns for each value
#' of a checkbox-field?
#' @param use_exact_dates TRUE/FALSE: Should the values from any "exact"
#' dates be used in case there are any? Default is FALSE.
#'
#' @return an "idaifield_simple" list
#' @export
#'
#'
#' @seealso \code{\link{idf_sepdim}}, \code{\link{remove_config_names}},
#' \code{\link{gather_languages}}, \code{\link{fix_dating}},
#' \code{\link{convert_to_onehot}}
#'
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
                               keep_geometry = FALSE,
                               replace_uids = TRUE,
                               uidlist = NULL,
                               language = "all",
                               spread_fields = TRUE,
                               use_exact_dates = FALSE) {

  check <- check_if_idaifield(idaifield_docs)
  if (check["idaifield_simple"] == TRUE) {
    message("Already of class 'idaifield_simple', did nothing.")
    return(idaifield_docs)
  }
  idaifield_docs <- check_and_unnest(idaifield_docs)

  if (is.null(uidlist)) {
    message("No UID-List supplied, generating from this list.")
    uidlist <- get_uid_list(idaifield_docs)
  }

  projectname <- attr(idaifield_docs, "projectname")
  conn <- attr(idaifield_docs, "connection")
  config <- try(get_configuration(conn, projectname = projectname))

  if (inherits(config, "try-error")) {
    fieldtypes <- NA
  } else {
    fieldtypes <- get_field_inputtypes(config, inputType = "all")

    ## Language handling / messages
    languages <- unlist(config$projectLanguages)
    if (language != "all") {
      if (language %in% languages) {
        message(paste("Keeping input values of selected language ('",
                      language, "') where possible.",
                      sep = ""))
      } else {
        new_language <- sort(languages[grepl("^[a-z]{2}$", languages)])
        new_language <- ifelse(is.null(new_language), "all", new_language[1])
        message(paste("Selected language ('",
                      language, "') not available. Trying '", new_language,
                      "' instead.", sep = ""))
        language <- new_language
      }
    } else {
      message("Keeping all languages for input fields.")
    }
  }

  idaifield_simple <- lapply(idaifield_docs, function(x)
    simplify_single_resource(
      x,
      replace_uids = replace_uids,
      uidlist = uidlist,
      keep_geometry = keep_geometry,
      fieldtypes = fieldtypes,
      language = language,
      spread_fields = spread_fields,
      use_exact_dates = use_exact_dates
    )
  )

  idaifield_simple <- structure(idaifield_simple, class = "idaifield_simple")
  attr(idaifield_simple, "connection") <- attr(idaifield_docs, "connection")
  attr(idaifield_simple, "projectname") <- attr(idaifield_docs, "projectname")
  attr(idaifield_simple, "language") <- language

  return(idaifield_simple)
}
