#' Find the Layer a resource is contained in
#'
#' Warning: recursive and currently no error handling
#'
#' Helper to simplify_single_resource(). Traces the liesWithin fields to
#' find the one that is a Layer and returns the corresponding identifier.
#'
#' #TODO: Somehow this is super convoluted.
#'
#'
#' @param resource One resource (element) from an idaifield_resources-list.
#' @param uidlist A data.frame as returned by `get_uid_list()`.
#' @param liesWithin Only for recursion: a dataframe this function hands
#' to itself, otherwith usually NULL
#' @param strict TRUE/FALSE (currently only for testing)
#'
#' @return chr
#' @keywords internal
find_layer <- function(resource = resource,
                       uidlist = NULL,
                       liesWithin = NULL,
                       strict = FALSE) {
  if (is.null(uidlist)) {
    warning("find_layer() called but no uidlist supplied")
    return(NA)
  }

  # get identifier, index and type of the parent resource
  liesWithin_index <- which(resource$relation.liesWithin == uidlist$identifier)
  liesWithin_identifier <- uidlist$identifier[liesWithin_index]
  liesWithin_type <- uidlist$type[liesWithin_index]

  # if there is no df names "liesWithin" yet (i.e. liesWithin = NULL), create
  # one with the data gathered above
  if (!is.data.frame(liesWithin)) {
    liesWithin <- data.frame(liesWithin_index = liesWithin_index,
                             liesWithin_identifier = liesWithin_identifier,
                             liesWithin_type = liesWithin_type)
  }

  # Add section in demo, explain how to configure the type lists and
  # also set up how this is handed down here from main function.
  # This is a possible feature but currently only exists so my tests will
  # be easier.
  layer_type_list <- getOption("idaifield_types")$layers
  if (strict) {
    layer_type_list <- getOption("idaifield_types")$layers_strict
  }

  # is any of the parent resources in the liesWithin-df a Layer?
  is_context <- liesWithin$liesWithin_type %in% layer_type_list
  if (any(is_context)) {
    # return the layer/context if there is one
    in_layer <- which(is_context)
    in_layer <- liesWithin$liesWithin_identifier[in_layer]
    return(in_layer)
  } else {
    # get the next row of the df to find its parent resources
    current <- nrow(liesWithin)
    # will not work with chr value as it has to be the index
    current <- as.numeric(liesWithin$liesWithin_index[current])
    # get the identifier of the next parent resource
    next_liesWithin_identifier <- uidlist$liesWithin[current]

    if (is.na(next_liesWithin_identifier) || length(current) == 0) {
      # this happens if there is no parent resource or no df
      return(NA)
    } else {
      # get the index and type of the parent
      next_liesWithin_index <- which(uidlist$identifier == next_liesWithin_identifier)
      next_liesWithin_type <- uidlist$type[next_liesWithin_index]
      # add as a row to the data.frame
      liesWithin <- rbind(liesWithin, c(next_liesWithin_index,
                                        next_liesWithin_identifier,
                                        next_liesWithin_type))
      # recursively call the function again to find the next parent, this
      # time with the data.frame already existing
      find_layer(resource = resource,
                 uidlist = uidlist,
                 liesWithin = liesWithin)
    }
  }
}

#' Break down a list from a checkbox field to onehot-coded values
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param resource A list from one of the measurement fields
#' (dimensionLength, dimensionWidth, etc.) from a single resource (element).
#' @param config A configuration list as returned by `get_configuration()`
#'
#' @return The resource object with the checkboxes seperated
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' config <- get_configuration(connection = conn,
#' projectname = "rtest")
#' idaifield_resources[[1]] <- convert_to_onehot(config,
#' idaifield_resources[[1]])
#' }
convert_to_onehot <- function(resource, config) {
  # get the inputType list
  checkboxes <- get_field_inputtypes(config, inputType = "checkboxes")

  # find which fields actually belong to the resource type
  correct_type <- which(checkboxes[,"type"] == resource$type)
  # manually add Feature and Find type because of problems
  correct_type <- c(correct_type,
                    which(checkboxes[,"type"] %in% c("Feature", "Find")))
  # get the index of the resource that should be converted
  index_to_convert <- which(names(resource) %in% checkboxes[correct_type,"field"])
  # add campaign field manually
  index_to_convert <- c(index_to_convert, which(names(resource) == "campaign"))

  # loop over the index to replace the checkbox-variable
  # with one-hot-coded versions
  for (i in index_to_convert) {
    var_name <- names(resource[i])
    var <- resource[[i]]
    new_vars <- rep(TRUE, length(var))
    names(new_vars) <- paste(var_name,".", var, sep = "")
    resource <- append(resource, new_vars)
  }
  # remove the old ones
  resource[index_to_convert] <- NULL
  return(resource)
}


#' Break down a list from a dimension field to a single value
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param dimensionList A list from one of the measurement fields
#' (dimensionLength, dimensionWidth, etc.) from a single resource (element).
#' @param name The name of the corresponding dimension List.
#'
#' @return A list containing simple values for each measured dimension from
#' the list; note: if a range was entered, it returns the mean without further
#' comment.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' dimensionLength_new <- idf_sepdim(idaifield_resources[[1]]$dimensionLength,
#' "dimensionLength")
#' }
idf_sepdim <- function(dimensionList, name = "dimensionLength") {
  dimno <- length(dimensionList)
  get_dim_value <- function(x) {
    if (is.null(x$value)) {
      # There is a problem with old entries, as the system was changed at some
      # point. Therefore we have to check if the there is an entry calles
      # "inputValue" first, because it may not be a range though value had not
      # been converted. If inputValue doesn't exist, it should be a range.
      if (is.null(x$inputValue)) {
        range <- c(x$rangeMin, x$rangeMax)
        value <- mean(range)/10000
        return(value)
      } else {
        # And then we need to do unit conversion...
        unit <- x$inputUnit
        value <- x$inputValue
        if (unit == "m") {
          value <- value * 100
          return(value)
        } else if (unit == "mm") {
          value <- value / 10
          return(value)
        } else if (unit == "cm") {
          return(value)
        }
      }
    } else {
      value <- x$value/10000
      return(value)
    }
  }

  if ("rangeMin" %in% names(dimensionList[[1]])) {
    name <- paste(name, "_mean", sep = "")
  }

  dims <- unlist(lapply(dimensionList, FUN = get_dim_value))
  names(dims) <- c(paste(name, "cm",
                         seq(from = 1, to = dimno, by = 1),
                         sep = "_"))
  dims <- as.list(dims)
  return(dims)
}

#' Remove everything before the : in a character vector
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param nameslist a character vector
#'
#' @return same character vector without everything before
#' the ":" including the ":"
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' nameslist <- c("relation.liesWithin","relation.liesWithinLayer",
#' "campaign.2022","milet:test")
#' nameslist <- remove_config_names(nameslist)
#' nameslist
#' }
remove_config_names <- function(nameslist = c("identifier","configname:test")) {
  nameslist <- gsub("^.*:", "", nameslist)
  return(nameslist)
}


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
                                     config = NULL) {


  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from a 'idaifield_resources'-list.")
  }

  resource <- fix_relations(resource,
                            replace_uids = replace_uids,
                            uidlist = uidlist)

  if (replace_uids) {
    liesWithinLayer <- find_layer(resource = resource,
                                  uidlist = uidlist,
                                  liesWithin = NULL)
    resource <- append(resource, list(relation.liesWithinLayer = liesWithinLayer))
  }


  if (!keep_geometry) {
    names <- names(resource)
    has_geom <- any(grepl("geometry", names))
    if (has_geom) {
      resource$geometry <- NULL
    }
  } else {
    resource$geometry <- reformat_geometry(resource$geometry)
  }

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



  list_names <- names(resource)

  if (any(grepl(":", list_names))) {
    list_names <- remove_config_names(list_names)
    names(resource) <- list_names
  }

  dim_names <- list_names[grep("dimension", list_names)]

  if (length(dim_names) >= 1) {
    new_dims <- as.list(1)
    for(dim in dim_names) {
      new_dims <- append(new_dims, idf_sepdim(resource[[dim]], dim))
    }
    new_dims <- as.list(unlist(new_dims[-1]))


    resource[dim_names] <- NULL

    resource <- append(resource, new_dims)
  }

  if (is.list(config)) {
    resource <- convert_to_onehot(resource = resource,
                                  config = config)
  }


  has_sublist <- suppressWarnings(vapply(resource,
                                         check_for_sublist,
                                         logical(1),
                                         USE.NAMES = FALSE))
  has_sublist <- which(unlist(has_sublist) == TRUE)


  for (i in seq_along(resource)) {
    if (!i %in% has_sublist) {
      res <- unname(unlist(resource[i]))
      if (length(res) > 1) {
        res <- list(res)
      }
      resource[i] <- na_if_empty(res)
    }
  }
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
                               uidlist = NULL) {
  if (is.null(uidlist)) {
    uidlist <- get_uid_list(idaifield_docs)
  }



  if (!is.null(attr(idaifield_docs, "connection"))) {
    connection <- attr(idaifield_docs, "connection")
    projectname <- attr(idaifield_docs, "projectname")
    config <- get_configuration(connection = connection,
                                projectname = projectname)
  }

  if (!exists("config")) {
    config <- NA
  }

  resources <- check_and_unnest(idaifield_docs)

  resources <- lapply(resources, function(x)
    simplify_single_resource(
      x,
      replace_uids = replace_uids,
      uidlist = uidlist,
      keep_geometry = keep_geometry,
      config = config
    )
  )

  resources <- structure(resources, class = "idaifield_resources")
  return(resources)
}
