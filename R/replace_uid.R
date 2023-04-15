#' Replace a Vector of UUIDs with their *identifier*s
#'
#' When handed an item (a vector or a single variable) first checks if it is
#' actually a UUID as defined in check_if_uid() and if so, replaces it with
#' the corresponding *identifier* from the uidlist (also handed to the function).
#'
#' @seealso
#' * This function is used in: [simplify_idaifield()], [fix_relations()]
#'
#' @param uidvector a vector of UUIDs to be replaced with their *identifier*s
#' @param uidlist a uidlist resp. index of as returned by
#' [get_uid_list()] and [get_field_index()]
#'
#' @returns The corresponding *identifier*(s) (a character string/vector)
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' index <- get_field_index(conn)
#'
#' replace_uid("02932bc4-22ce-3080-a205-e050b489c0c2", uidlist = index[, c("identifier", "UID")])
#' }
replace_uid <- function(uidvector, uidlist) {
  opt <- c("UID", "UUID", "id")
  which <- opt %in% colnames(uidlist)
  sel <- opt[which]

  identifier <- uidlist$identifier
  uuids <- uidlist[, sel]

  matches <- match(uidvector, uuids)

  result <- ifelse(is.na(matches), uidvector, identifier[matches])

  return(result)
}
