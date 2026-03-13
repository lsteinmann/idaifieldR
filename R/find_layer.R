#' Find the Layer a Resource is Contained in
#'
#' Helper to [simplify_idaifield()]. Traces the liesWithin fields to
#' find the one that is a Layer and returns the corresponding identifier.
#'
#'
#' @param ids Either the UUIDs or the identifiers resources from an
#' `idaifield_...`-list as returned by [get_idaifield_docs()], [idf_query()],
#' [idf_index_query()] or [idf_json_query()].
#' @param index A data.frame as returned by [get_field_index()] or
#' [get_uid_list()].
#' @param layer_categories A vector of *categories* that are classified as
#' *Layer*s.
#' @param max_depth numeric. Maximum number of recursive
#' iterations / maximum depth a resource may be nested below its layer.
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
#'
#'  # For a nested Find:
#' index[which(index$identifier == "Befund_1_InschriftAufMünze"), ]
#' find_layer("Befund_1_InschriftAufMünze", index)
#'
#' # For all resources:
#' find_layer(index$identifier, index)
#' }
find_layer <- function(ids,
                       index = NULL,
                       layer_categories = NULL,
                       max_depth = 20) {

  stopifnot(is.numeric(max_depth))

  if (is.null(ids)) {
    stop("Need either an identifier or a UUID as 'id = '.")
  }
  if (is.null(index)) {
    warning("`find_layer()` called but no index supplied.")
    return(rep(NA, length(ids)))
  }
  if (is.null(layer_categories)) {
    stop("No 'layer_categories'.")
  }

  proj_conf_ind <- which(ids %in% c("project", "configuration"))
  check <- check_if_uid(ids)
  if (length(proj_conf_ind) >= 1) {
    check <- check[-proj_conf_ind]
  }

  if (all(check)) {
    id_type <- "UID"
  } else {
    id_type <- "identifier"
  }

  id_type <- match.arg(id_type, c("identifier", "UID", "UUID", "id"),
                       several.ok = FALSE)
  id_type <- which(colnames(index) == id_type)


  parents <- find_parents(ids, index, id_type)
  parents_cats <- find_categories(parents, index, id_type)

  parent_list <- list(
    solved = list(identifier = character(length = 0),
                  liesWithinLayer = character(length = 0)),
    unsolved = list(identifier = ids,
                    search_for = ids,
                    parents_of_sf = parents,
                    parents_of_sf_cat = parents_cats)
  )

  res_list <- find_parent_layer(parent_list, index,
                           id_type, layer_categories,
                           max_depth = max_depth)


  if (length(res_list$solved$identifier) == 0) {
    return(rep(NA, length(ids)))
  } else {
    result <- ids
    matched <- match(res_list$solved$identifier, ids)
    result[-matched] <- NA
    result[matched] <- res_list$solved$liesWithinLayer
    names(result) <- ids

    return(result)
  }
}


#' returns the UUID/identifier of the resources the 'ids' are contained in
#'
#' @seealso
#' * [find_layer()].
#'
#' @inheritParams find_parent_layer
#'
#' @keywords internal
#'
#' @return a vector of resources in which each id is located
find_parents <- function(ids, index, id_type) {
  parents <- index$liesWithin[match(ids, index[, id_type])]
  return(parents)
}

#' returns the category of the ids (UUID/identifier)
#'
#' @seealso
#' * [find_layer()].
#'
#' @inheritParams find_parent_layer
#'
#' @keywords internal
#'
#' @return a vector of categories for each resource
find_categories <- function(ids, index, id_type) {
  cats <- index$category[match(ids, index[, id_type])]
  return(cats)
}



#' takes and returns a parent list recursively
#' until as much as possible is solved
#'
#' @seealso
#' * [find_layer()].
#'
#' @inheritParams find_layer
#' @param id_type One of "identifier" or "UID" - Should the function use
#' *identifier*s or *UUID*s to find the layer?
#' @param parent_list a list with solved and unsolved resources
#'
#' @keywords internal
#'
#' @return a list with solved and unsolved resources
find_parent_layer <- function(parent_list, index, id_type, layer_categories,
                              max_depth = 20) {
  ids <- parent_list$unsolved$search_for
  identifier <- parent_list$unsolved$identifier

  # get their parent resources uuid/identifier
  ids_parents <- parent_list$unsolved$parents_of_sf
  # get the category of each parent
  cat_parents <- parent_list$unsolved$parents_of_sf_cat
  # see if the parents are layers
  parent_is_layer <- cat_parents %in% layer_categories

  # every item that has true here can be considered solved,
  # so we will store the info in a list
  solved <- identifier[parent_is_layer]
  solved_parents <- ids_parents[parent_is_layer]

  if (length(solved) == 0) {
    unsolved <- identifier
  } else {
    unsolved <- identifier[-match(solved, identifier)]
  }

  unsolved_parents <- ids_parents[!parent_is_layer]
  parents_of_sf <- find_parents(unsolved_parents, index, id_type)
  parent_list <- list(
    solved = list(identifier = c(parent_list$solved$identifier, solved),
                  liesWithinLayer = c(parent_list$solved$liesWithinLayer, solved_parents)),
    unsolved = list(identifier = unsolved,
                    search_for = unsolved_parents,
                    parents_of_sf = parents_of_sf,
                    parents_of_sf_cat = find_categories(parents_of_sf, index, id_type))
  )
  # or return when all search_for is NA, failsafe or it is time to give up
  len_remaining <- length(parent_list$unsolved$search_for)
  remaining_all_na <- all(is.na(parent_list$unsolved$search_for))
  if (len_remaining == 0 | remaining_all_na == TRUE | max_depth < 1) {
    return(parent_list)
  } else {
    find_parent_layer(parent_list, index,
                      id_type, layer_categories,
                      max_depth = max_depth - 1)
  }
}
