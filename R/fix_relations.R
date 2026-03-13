#' Flatten Relations and Optionally Replace UUIDs
#'
#' Flattens the nested `relations` list of a resource into individual named
#' vectors with a `relation.`-prefix (e.g. `relation.isAbove`), and
#' optionally replaces UUIDs with human-readable identifiers from the index.
#'
#' @param resource One element from an `idaifield_resources` list.
#' @param replace_uids logical. Should UUIDs be replaced with identifiers
#' from `index`? Default is TRUE.
#' @param index A data.frame as returned by [get_uid_list()] or
#' [get_field_index()]. Required if `replace_uids = TRUE`.
#'
#' @returns The resource with its `relations` list removed and replaced by
#' flat named vectors, one per relation type.
#'
#' @seealso [replace_uid()], [simplify_idaifield()]
#' @export
#'
#' @examples
#' \dontrun{
#' index <- data.frame(
#'   identifier = c("name1", "name2"),
#'   UID = c("15754929-dd98-acfa-bfc2-016b4d5582fe",
#'           "bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
#' )
#' resource <- list(
#'   identifier = "res_1",
#'   relations = list(
#'     isRecordedIn = list("15754929-dd98-acfa-bfc2-016b4d5582fe"),
#'     liesWithin = list("bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
#'   )
#' )
#' fix_relations(resource, replace_uids = TRUE, index = index)
#' fix_relations(resource, replace_uids = FALSE)
#' }
fix_relations <- function(resource, replace_uids = TRUE, index = NULL,
                          # DEPRECATED
                          uidlist = NULL) {
  if (!is.null(uidlist)) {
    warning("'uidlist' argument has been renamed to 'index'. do not use it anymore.")
    if (is.null(index)) {
      index <- uidlist
    }
  }
  if (replace_uids == TRUE && !is.data.frame(index)) {
    stop("replace_uids = TRUE but no index supplied")
  }
  relations <- resource$relations
  if (length(relations) > 0) {
    relations <- lapply(relations, function(relation) {
      relation <- unlist(relation)
      if (replace_uids) {
        relation <- replace_uid(relation, index)
      }
      return(relation)
    })
    names(relations) <- paste0("relation.", names(relations))
    resource$relations <- NULL
    resource <- append(resource, relations)
  } else {
    resource$relations <- NULL
  }
  return(resource)
}
