#' Simplifies a single resource from the i.DAIfield 2 Database
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
#' @export
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
  if (!keep_geometry) {
    names <- names(resource)
    has_geom <- any(grepl("geometry", names))
    if (has_geom) {
      resource$geometry <- NULL
    }
  } else {
    resource$geometry <- reformat_geometry(resource$geometry)
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





#' Simplify a list imported from an i.DAIfield-Database
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
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
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
