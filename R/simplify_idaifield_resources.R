#' Title
#'
#' @param resource
#' @param replace_uids
#' @param uidlist
#' @param keep_geometry
#'
#' @return
#' @export
#'
#' @examples
simplify_single_resource <- function(resource,
                                     replace_uids = TRUE,
                                     uidlist = uidlist,
                                     keep_geometry = FALSE
                                     ) {
  stopifnot(nrow(uidlist) > 1)
  resource <- fix_relations(resource,
                            replace_uids = TRUE,
                            uidlist = uidlist)
  if (!keep_geometry) {
    names <- names(resource)
    has_geom <- any(grepl("geometry", names))
    if (has_geom) {
      resource$geometry <- NULL
    }
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





#' Title
#'
#' @param idaifield_docs
#' @param replace_uids
#' @param uidlist
#'#'
#' @param keep_geometry FALSE by default. TRUE if you wish to import the
#' geometry-fields into R (TODO: this is not reachable from top level function)
#'
#' needs: keep_geometry; unnest relations
#'
#' @return
#' @export
#'
#' @examples
simplify_idaifield <- function(idaifield_docs,
                               replace_uids = TRUE,
                               uidlist = "generate") {
  if (uidlist == "generate") {
    uidlist <- get_uid_list(idaifield_docs)
  }
  resources <- check_and_unnest(idaifield_docs)

  resources <- lapply(resources, function(x) simplify_single_resource(
    x,
    replace_uids = TRUE,
    uidlist = uidlist,
    keep_geometry = FALSE)
    )

  resources <- structure(resources, class = "idaifield_resources")
  return(resources)
}
