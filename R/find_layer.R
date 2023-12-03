#' Find the Layer a Resource is Contained in
#'
#' Helper to [simplify_idaifield()]. Traces the liesWithin fields to
#' find the one that is a Layer and returns the corresponding identifier.
#'
#'
#' @param id Either the UUID or the identifier of a resource from an
#' `idaifield_...`-list as returned by [get_idaifield_docs()], [idf_query()],
#' [idf_index_query()] or [idf_json_query()].
#' @param id_type one of "identifier" or "UID" - Should the function use
#' *identifier*s or *UUID*s to find the layer?
#' @param uidlist A data.frame as returned by [get_field_index()] or
#' [get_uid_list()].
#' @param layer_categories A vector of *categories* that are classified as
#' *Layer*s. See or change the default: `getOption("idaifield_categories")$layers`
#'
#'
#' @returns The identifier or UUID of the first "Layer"-category resource the
#' given id/identifier lies within.
#'
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()], [get_field_index()],
#' [get_uid_list()].
#'
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' index <- get_field_index(conn)
#' index[which(index$identifier == "Befund_1_InschriftAufMünze"), ]
#' find_layer("Befund_1_InschriftAufMünze", id_type = "identifier", index)
#' }
find_layer <- function(id,
                       id_type = "identifier",
                       uidlist = NULL,
                       layer_categories = NULL) {

  if (all(check_if_uid(id)) | id %in% c("project", "configuration")) {
    id_type <- "UID"
  } else {
    id_type <- "identifier"
  }

  id_type <- match.arg(id_type, c("identifier", "UID", "UUID", "id"),
                       several.ok = FALSE)
  id_type <- which(colnames(uidlist) == id_type)
  if (is.null(id)) {
    stop("Need either an identifier or a UUID as 'id = '.")
  }
  if (is.null(uidlist)) {
    warning("find_layer() called but no uidlist supplied")
    return(NA)
  }

  if (is.null(layer_categories)) {
    layer_categories <- getOption("idaifield_categories")$layers
  }


  all_ids <- uidlist[, id_type]
  current <- match(id, all_ids)
  all_cats <- uidlist$category
  all_lw <- uidlist$liesWithin

  current_cat <- all_cats[current]
  start_lw <- all_lw[current]

  if (current_cat %in% c(layer_categories, "Feature")) {
    return(start_lw)
  }
  if (is.na(start_lw)) {
    return(NA)
  }

  while(!(current_cat %in% layer_categories)) {
    current_cat <- all_cats[current]
    if (current_cat %in% layer_categories) {
      return(all_ids[current])
    }
    liesWithin <- all_lw[current]
    if (is.na(liesWithin)) {
      return(NA)
    }
    current <- match(liesWithin, all_ids)
  }

}
