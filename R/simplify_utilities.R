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
convert_to_onehot <- function(resource, fieldtypes) {
  # get the inputType list
  checkboxes <- fieldtypes[which(fieldtypes[,"inputType"] == "checkboxes"),]

  # find which fields actually belong to the resource type
  correct_type <- which(checkboxes[, "type"] == resource$type)
  # manually add Feature and Find type because of problems
  # wtf does that even mean
  correct_type <- c(correct_type,
                    which(checkboxes[, "type"] %in% c("Feature", "Find")))
  # get the index of the resource that should be converted
  index_to_convert <- which(names(resource) %in% checkboxes[correct_type, "field"])
  # add campaign field manually
  index_to_convert <- c(index_to_convert, which(names(resource) == "campaign"))

  # loop over the index to replace the checkbox-variable
  # with one-hot-coded versions
  for (i in index_to_convert) {
    var_name <- names(resource[i])
    var <- resource[[i]]
    new_vars <- rep(TRUE, length(var))
    names(new_vars) <- paste(var_name, ".", var, sep = "")
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
        value <- mean(range) / 10000
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
      value <- x$value / 10000
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


