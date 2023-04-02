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
#' @param uidlist A data.frame as returned by `get_field_index()`.
#' @param liesWithin Only for recursion: a dataframe this function hands
#' to itself, otherwith usually NULL
#' @param strict TRUE/FALSE (currently only for testing)
#'
#' @return chr
#' @keywords internal
find_layer <- function(resource = resource,
                       uidlist = NULL,
                       liesWithin = NULL,
                       strict = FALSE,
                       opts = NULL) {
  if (is.null(opts)) {
    # The function first checks if an uidlist has been supplied,
    # and if not it outputs a warning message and returns NA.
    if (is.null(uidlist)) {
      warning("find_layer() called but no uidlist supplied")
      return(NA)
    }

    lwl_names <- c("liesWithinLayer",
                   "relation.liesWithinLayer",
                   "relations.liesWithinLayer")
    lwl_names <- lwl_names %in% names(resource)
    if (any(lwl_names)) {
      #message("liesWithinLayer already present, ignoring.")
      return(resource)
    }

    lw_col <- c("liesWithin",
                "relation.liesWithin",
                "relations.liesWithin")
    lw_col <- which(names(resource) %in% lw_col)
    if (length(lw_col) == 0) {
      #message("Resource contains no 'liesWithin'.")
      return(NA)
    }

    if (any(check_if_uid(resource[[lw_col]]))) {
      warning("Replace UUIDs before calling find_layer.")
      return(resource)
    }


    category_names <- c("type", "category")
    category_col <- which(colnames(uidlist) %in% category_names)

    # get identifier, uidlist and type of the parent resource
    # match should be fine here as identifiers are unique and liesWithin can only
    # have one value as well
    liesWithin_index <- match(resource[[lw_col]], uidlist$identifier)
    liesWithin_identifier <- uidlist$identifier[liesWithin_index]
    liesWithin_category <- uidlist[liesWithin_index, category_col]

    # if there is no df names "liesWithin" yet (i.e. liesWithin = NULL), create
    # one with the data gathered above
    if (is.null(liesWithin)) {
      liesWithin <- list(liesWithin_index = liesWithin_index,
                         liesWithin_identifier = liesWithin_identifier,
                         liesWithin_category = liesWithin_category)
    }

    # Add section in demo, explain how to configure the type lists and
    # also set up how this is handed down here from main function.
    # This is a possible feature but currently only exists so my tests will
    # be easier.
    layer_categories_list <- getOption("idaifield_categories")$layers
    if (strict) {
      layer_categories_list <- getOption("idaifield_categories")$layers_strict
    }
  } else if (is.list(opts)) {
    # assumes that the function has been called from itself
    layer_categories_list <- opts$layer_categories_list
    category_col <- opts$category_col
  } else {
    stop("no")
  }


  # is any of the parent resources in the liesWithin-list a Layer?
  is_context <- liesWithin$liesWithin_category %in% layer_categories_list
  if (any(is_context)) {
    # return the layer/context if there is one
    in_layer <- which(is_context)
    layer <- unlist(liesWithin$liesWithin_identifier, use.names = FALSE)
    layer <- layer[in_layer]
    return(layer)
  } else {
    # get the next row of the df to find its parent resources
    current <- length(liesWithin$liesWithin_identifier)
    # will not work with chr value as it has to be the index
    current <- as.numeric(liesWithin$liesWithin_index[current])
    # get the identifier of the next parent resource
    next_liesWithin_identifier <- uidlist$liesWithin[current]

    if (is.na(next_liesWithin_identifier) || length(current) == 0) {
      # this happens if there is no parent resource or no df
      return(NA)
    } else {
      # get the index and type of the parent
      # match should be fine here as identifiers are unique
      next_liesWithin_index <- match(next_liesWithin_identifier, uidlist$identifier)
      next_liesWithin_category <- uidlist[next_liesWithin_index, category_col]
      # add to the list
      liesWithin$liesWithin_index <- c(liesWithin$liesWithin_index,
                                       next_liesWithin_index)
      liesWithin$liesWithin_identifier <- c(liesWithin$liesWithin_identifier,
                                            next_liesWithin_identifier)
      liesWithin$liesWithin_category <- c(liesWithin$liesWithin_category,
                                          next_liesWithin_category)
      # recursively call the function again to find the next parent, this
      # time with the data.frame already existing
      find_layer(resource = resource,
                 uidlist = uidlist,
                 liesWithin = liesWithin,
                 opts = list(layer_categories_list = layer_categories_list,
                             category_col = category_col))
    }
  }
}

