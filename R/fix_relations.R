#' Unnest the Relations in a Resource and Replace the UUIDs with *identifiers*
#'
#' The function will flatten the relations list to more non-nested lists with
#' with *relation.*-prefix and replace the UUIDs in the lists values with
#' the corresponding *identifier*s from the uidlist/index
#' (see [get_field_index()] or [get_uid_list()]) using
#' [replace_uid()] to make the result more readable.
#'
#' @param resource One element from a list of class `idaifield_resources`.
#' @param replace_uids TRUE/FALSE. If TRUE, replaces the UUIDs in each relation
#' with the corresponding identifiers. If FALSE, just flattens the list.
#' Default is TRUE.
#' @param uidlist Only needs to be provided if `replace_uids = TRUE`.
#' A data.frame as returned by [get_uid_list()] or
#' [get_field_index()].
#'
#' @returns The same resource with its relations unnested (and replaced with
#' *identifier*s if `replace_uids` is set to `TRUE`).
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()].
#'
#' @export
#'
#' @examples
#' \dontrun{
#' index <- data.frame(
#'   identifier = c("name1", "name2"),
#'   UID = c("15754929-dd98-acfa-bfc2-016b4d5582fe",
#'           "bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
#'  )
#' resource <- list(relations = list(
#'     isRecordedIn = list("15754929-dd98-acfa-bfc2-016b4d5582fe"),
#'     liesWithin = list("bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
#'   ),
#'   identifier = "res_1"
#' )
#'
#' new_relations_list <- fix_relations(resource, replace_uids = TRUE, uidlist = index)
#' new_relations_list
#'
#' new_relations_list <- fix_relations(resource, replace_uids = FALSE)
#' new_relations_list
#' }
fix_relations <- function(resource, replace_uids = TRUE, uidlist = NULL) {
  # ensure that the uidlist argument is correctly formatted
  # when replace_uids is TRUE.
  if (replace_uids == TRUE && !is.data.frame(uidlist)) {
    stop("replace_uids = TRUE but no UIDlist supplied")
  }
  # unlist/flatten the relations list and check if the resource has relations
  # (meaning the list is not empty)
  relationslist <- unlist(resource$relations)
  if (length(relationslist) > 0) {
    # get the names of the elements in relationslist and removes all numeric
    # characters using gsub().
    names <- gsub("\\d", "", names(relationslist))
    # If the replace_uids argument is TRUE, replaces the unique IDs in
    # relationslist with identifiers gathered from the uidlist.
    if (replace_uids) {
      relationslist <- replace_uid(relationslist, uidlist)
    }
    # The function then creates new names for the elements in relationslist by
    # prepending "relation." to the existing names. The new names are then
    # assigned to relationslist and the list is split into a list of lists,
    # with each sub-list containing the elements that have the same name.
    # The relations field of the resource is then removed and the resulting
    # relationslist is appended to the resource.
    names <- paste("relation.", names, sep = "")
    names(relationslist) <- names
    relationslist <- split(unname(relationslist), names(relationslist))
    resource$relations <- NULL
    resource <- append(resource, relationslist)
  } else {
    # If the relations field of the resource is empty, it is simply removed.
    resource$relations <- NULL
  }
  # Finally, the modified resource is returned by the function.
  return(resource)
}
