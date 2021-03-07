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
  if (nrow(uidlist) > 1) {
    resource <- fix_relations(resource,
                              replace_uids = TRUE,
                              uidlist = uidlist)
  } else {
    stop("problem with uidlist")
  }
  if (!keep_geometry) {
    names <- names(resource)
    has_geom <- any(grepl("geometry", names))
    if (has_geom) {
      resource$geometry <- NULL
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
  return(resources)
}
