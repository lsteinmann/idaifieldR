#' Unnest the relations in a resource and replace the UUIDs with identifiers
#'
#' The function will flatten the relations list to more non-nested lists with
#' with "relation."-prefix and replace the UUIDs in the lists values with
#' the corresponding identifiers from the uidlist using
#' \code{\link{replace_uid}} to make the result more readable.
#'
#' @param resource One item from a list of class idaifield_resources
#' @param replace_uids TRUE/FALSE. If TRUE, replaces the UUIDs in each relation
#' with the corresponding identifiers. If FALSE, just unnests the list.
#' Default is TRUE.
#' @param uidlist Only needs to be provided if replace_uids = TRUE.
#' A data.frame as returned by \code{\link{get_uid_list}} or
#' \code{\link{get_field_index}}.
#'
#' @return The same resource with its relations unnested (and replaced with
#' identifiers if `replace_uids` is set to `TRUE`).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' new_relations_list <- fix_relations(resource,
#' replace_uids = FALSE,
#' uidlist = NULL)
#' }
fix_relations <- function(resource, replace_uids = TRUE, uidlist = NULL) {
  # ensure that the uidlist argument is correctly formatted
  # when replace_uids is TRUE.
  if (replace_uids == TRUE && !is.data.frame(uidlist)) {
    stop("replace_uids = TRUE but no UIDlist supplied")
  }
  # checks if the relations field of the resource is non-empty,
  if (length(resource$relations) > 0) {
    # and if so, assigns it to the relationslist variable, flattened
    # (i.e., converted to a vector) using unlist(). The function then
    # gets the names of the elements in relationslist and removes all numeric
    # characters using gsub().
    relationslist <- unlist(resource$relations)
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
