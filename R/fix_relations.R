#' Unnest the relations in a resource
#'
#' @param resource One item from a list of class idaifield_resources
#' @param replace_uids logical. If TRUE, replaces the UIDs in each relation with
#' the corresponding identifiers. If FALSE, just unnests the list.
#' @param uidlist Only needs to be provided if replace_uids = TRUE. A data.frame
#' as returned by `get_uid_list()`
#'
#' @return The resource with its relations unnested (and replaced with
#' identifiers if replace_uids is set to TRUE).
#'
#' @export
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' new_relations_list <- fix_relations(resource,
#' replace_uids = FALSE,
#' uidlist = NULL)
#' }
fix_relations <- function(resource, replace_uids = TRUE, uidlist = NULL) {
  if (replace_uids == TRUE && !is.data.frame(uidlist)) {
    stop("replace_uids = TRUE but no concordance of UIDs supplied")
  }
  if (length(resource$relations) > 0) {
    relations <- resource$relations
    if (replace_uids) {
      relations <- lapply(relations,
                          function(x) replace_uid(x, uidlist = uidlist))
    } else if (!replace_uids) {
      relations <- lapply(relations, unlist)
    }
    names(relations) <- paste("relation.", names(relations), sep = "")
    resource$relations <- NULL
    resource <- append(resource, relations)
  } else {
    resource$relations <- NULL
  }
  return(resource)
}
