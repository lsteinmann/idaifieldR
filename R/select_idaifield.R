#' show_categories
#'
#' Returns a list of categories present in the iDAI.field 2 / Field Desktop database.
#'
#' @param idaifield_docs An object as returned by `get_idaifield_docs(...)`;
#' unnests to resource level if it didn't already happen.
#'
#' @return a character vector with the types represented in
#' the idaifield_docs/resource
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#'                                 user = "R",
#'                                 pwd = "hallo",
#'                                 project = "rtest")
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' show_categories(idaifield_docs)
#' }
show_categories <- function(idaifield_docs) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  uid_category_list <- get_uid_list(idaifield_docs)
  db_categories <- unique(uid_category_list$category)
  return(db_categories)
}


#' select_by
#'
#' returns a subset of the docs list selected by category or isRecordedIn
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#' @param by must be either category (to select by resource category) or
#' isRecordedIn (to select by container-resource (Survey-Area, Trench))
#' @param value Character expected, should be the internal Name of the
#' that will be selected for (e.g. "Layer", "Pottery"), can be vector of
#' multiple Categories / Operations
#'
#' @return a list of class idaifield_resources containing the resources
#' which are of the selected category
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo", project = "rtest")
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' idaifield_layers <- select_by(idaifield_docs,
#' by = "category",
#' value = "Layer")
#' }
select_by <- function(idaifield_docs,
                      by = c("category", "isRecordedIn"),
                      value = NULL) {

  if (length(by) > 1) {
    message("Please select only one of 'category' or 'isRecordedIn' (using first)")
    by <- by[1]
  }
  if (is.null(value)) {
    stop("No value given for selection.")
  }

  idaifield_docs <- check_and_unnest(idaifield_docs)
  uidlist <- get_uid_list(idaifield_docs)

  col <- colnames(uidlist) == by

  ind <- which(uidlist[, col] %in% value)

  selected_docs <- idaifield_docs[ind]
  selected_docs <- structure(selected_docs, class = "idaifield_resources")


  attributes <- attributes(idaifield_docs)
  attributes(selected_docs) <- attributes[-which(names(attributes) == "names")]
  names(selected_docs) <- names(idaifield_docs[ind])

  return(selected_docs)
}
