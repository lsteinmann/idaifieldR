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
                       strict = TRUE) {
  if (is.null(uidlist)) {
    warning("find_layer() called but no uidlist supplied")
    return(NA)
  }

  liesWithin_index <- which(resource$relation.liesWithin == uidlist$identifier)
  liesWithin_identifier <- uidlist$identifier[liesWithin_index]
  liesWithin_type <- uidlist$type[liesWithin_index]

  if (!is.data.frame(liesWithin)) {
    liesWithin <- data.frame(liesWithin_index = liesWithin_index,
                             liesWithin_identifier = liesWithin_identifier,
                             liesWithin_type = liesWithin_type)
  }

  # Add section in demo, explain how to configure the type lists and
  # also set up how this is handed down here from main function.
  # This is a possible feature but currently only exists so my tests will
  # be easier.
  layer_type_list <- getOption("idaifield_types")$layers_strict
  if (!strict) {
    layer_type_list <- getOption("idaifield_types")$layers
  }

  is_context <- liesWithin$liesWithin_type %in% layer_type_list
  if (any(is_context)) {
    in_layer <- which(is_context)
    in_layer <- liesWithin$liesWithin_identifier[in_layer]
    return(in_layer)
  } else {
    current <- nrow(liesWithin)
    current <- liesWithin$liesWithin_index[current]
    next_liesWithin_identifier <- uidlist$liesWithin[current]

    if (is.na(next_liesWithin_identifier) || length(current) == 0) {
      return(NA)
    } else {
      next_liesWithin_index <- which(uidlist$identifier == next_liesWithin_identifier)
      next_liesWithin_type <- uidlist$type[next_liesWithin_index]
      liesWithin <- rbind(liesWithin, c(next_liesWithin_index,
                                        next_liesWithin_identifier,
                                        next_liesWithin_type))
      find_layer(resource = resource,
                 uidlist = uidlist,
                 liesWithin = liesWithin)
    }
  }
}

#' Simplifies a single resource from the iDAI.field 2 Database
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
                                     keep_geometry = FALSE
                                     ) {
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
                               keep_geometry = FALSE,
                               replace_uids = TRUE,
                               uidlist = NULL) {
  if (is.null(uidlist)) {
    uidlist <- get_uid_list(idaifield_docs)
  }
  resources <- check_and_unnest(idaifield_docs)

  resources <- lapply(resources, function(x)
    simplify_single_resource(
      x,
      replace_uids = replace_uids,
      uidlist = uidlist,
      keep_geometry = keep_geometry
    )
  )

  resources <- structure(resources, class = "idaifield_resources")
  return(resources)
}
