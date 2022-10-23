#' replace_uid
#'
#' When handed an item (a vector or a single variable) first checks if it is
#' actually a UID as defined in check_if_uid() and if so, replaces it with
#' the corresponding identifier from the uidlist (also handed to the function).
#'
#'
#'
#' @param uidvector a vector of UIDs to be replaced with their identifiers (if
#' numeric, the corresponging column of the uidlist is processed)
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

  check_if_uid(uidvector)

  if (is.numeric(uidvector)) {
    uidvector <- uidlist[, uidvector]
  }

  mat <- matrix(ncol = 2, nrow = length(uidvector))
  mat[, 1] <- as.character(uidvector)
  matches <- match(mat[, 1], uidlist$UID)
  mat[, 2] <- ifelse(check_if_uid(mat[, 1]),
                    uidlist$identifier[matches],
                    mat[, 1])

  return(mat[, 2])
}
