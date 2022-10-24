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
                                     fieldtypes = NULL) {
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

  if (any(grepl(":", resource$type))) {
    resource$type <- remove_config_names(resource$type)
  }

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

  if (is.matrix(fieldtypes)) {
    resource <- convert_to_onehot(resource = resource,
                                  fieldtypes = fieldtypes)
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
  }
  idaifield_docs <- check_and_unnest(idaifield_docs)

  idaifield_docs <- lapply(idaifield_docs, function(x)
    simplify_single_resource(
      x,
      replace_uids = replace_uids,
      uidlist = uidlist,
      keep_geometry = keep_geometry,
      fieldtypes = fieldtypes
    )
  )

  idaifield_docs <- structure(idaifield_docs, class = "idaifield_simple")
  attr(idaifield_docs, "connection") <- connection
  attr(idaifield_docs, "projectname") <- projectname

  return(idaifield_docs)
}
