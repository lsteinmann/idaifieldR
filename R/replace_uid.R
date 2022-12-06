#' replace_uid
#'
#' When handed an item (a vector or a single variable) first checks if it is
#' actually a UID as defined in check_if_uid() and if so, replaces it with
#' the corresponding identifier from the uidlist (also handed to the function).
#'
#'
#'
#' @param uidvector a vector of UIDs to be replaced with their identifiers
#' @param uidlist a uidlist as returned by get_uid_list()
#'
#' @return The corresponding identifier(s) (a character string/vector)
#'
#' @export
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' uidlist <- get_uid_list(idaifield_docs)
#'
#' replace_uid("9e436b96-134d-e610-c032-136fc9e8e26e", uidlist = uidlist)
#' }
replace_uid <- function(uidvector, uidlist) {
  # Create a logical vector indicating which entries in uidvector are in uidlist
  matches <- match(uidvector, uidlist$UID)

  # Return the corresponding entries in uidlist,
  # or the original entries if no match is found
  identifiers <- ifelse(is.na(matches), uidvector, uidlist$identifier[matches])

  # Check for remaining UUIDs in uidvector
  is_uid <- check_if_uid(identifiers)
  if (any(is_uid)) {
    message("Not all UIDs were replaced.")
  }
  return(identifiers)
}
