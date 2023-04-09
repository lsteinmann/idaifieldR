#' Replace a vector of UUIDs with their identifiers
#'
#' When handed an item (a vector or a single variable) first checks if it is
#' actually a UUID as defined in check_if_uid() and if so, replaces it with
#' the corresponding identifier from the uidlist (also handed to the function).
#'
#' @seealso \code{\link{simplify_idaifield}}, \code{\link{fix_relations}}
#'
#' @param uidvector a vector of UUIDs to be replaced with their identifiers
#' @param uidlist a uidlist resp. index of as returned by
#' \code{\link{get_uid_list}} and \code{\link{get_field_index}}
#'
#' @return The corresponding identifier(s) (a character string/vector)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' uidlist <- get_uid_list(idaifield_docs)
#'
#' replace_uid("9e436b96-134d-e610-c032-136fc9e8e26e", uidlist = uidlist)
#' }
replace_uid <- function(uidvector, uidlist) {
  opt <- c("UID", "UUID", "id")
  which <- opt %in% colnames(uidlist)
  sel <- opt[which]

  # Create a logical vector indicating which entries in uidvector are in uidlist
  matches <- match(uidvector, uidlist[, sel])

  # Return the corresponding entries in uidlist,
  # or the original entries if no match is found
  identifiers <- ifelse(is.na(matches), uidvector, uidlist$identifier[matches])

  # Check for remaining UUIDs in uidvector
  #is_uid <- check_if_uid(identifiers)
  #if (any(is_uid)) {
  #  message("Not all UIDs were replaced.")
  #}
  return(identifiers)
}
