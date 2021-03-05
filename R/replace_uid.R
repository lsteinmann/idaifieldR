#' replace_uid
#'
#' When handed an item (a vector or a single variable) first checks if it is
#' actually a UID as defined in check_if_uid() and if so, replaces it with
#' the corresponding identifier from the uidlist (also handed to the function).
#'
#'
#'
#' @param item A vector (does not handle lists)
#' @param uidlist a uidlist as returned by get_uid_list()
#'
#' @return The corresponding identifier(s) (a character string/vector)
#' @export
#'
#' @examples
#' \dontrun{
#' uidlist <- get_uid_list(idaifield_docs)
#'
#' replace_uid("9e436b96-134d-e610-c032-136fc9e8e26e", uidlist = uidlist)
#' }
replace_uid <- function(item, uidlist) {
  if (check_if_uid(item)) {
    index <- match(item, uidlist$UID)
    identifier <- uidlist$identifier[index]
    return(identifier)
  } else {
    return(item)
  }
}
