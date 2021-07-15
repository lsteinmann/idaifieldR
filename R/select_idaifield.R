#' show_type_list
#'
#' Returns a list of types present in the iDAI.field 2-database
#' (for orientation) it would be nice to be able to embed the translations,
#' but i am guessing thats only possible if the configuration was available
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...);
#' unnests to resource level if it didn't already happen.
#'
#' @return a character vector with the types represented in
#' the idaifield_docs/resource
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "192.168.2.21",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest")
#'
#' show_type_list(idaifield_docs)
#' }
show_type_list <- function(idaifield_docs) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  uid_type_list <- get_uid_list(idaifield_docs)
  db_types <- unique(uid_type_list$type)
  return(db_types)
}


#' select_by
#'
#' returns a subset of the docs list selected by type or isRecordedIn
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#' @param by must be either type (to select by resource type) or isRecordedIn
#' (to select by container-resource (Survey-Area, Trench))
#' @param value Character expected, should be the internal Name of the Type
#' that will be selected for (e.g. "Layer", "Pottery"), can be vector of
#' multiple Types / Operations
#'
#' @return a list of class idaifield_resources containing the resources
#' which are of the selected type
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "192.168.2.21",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest")
#'
#' idaifield_layers <- select_by_type(idaifield_docs,
#' by = "type",
#' value = "Layer")
#' }
select_by <- function(idaifield_docs,
                      by = c("type", "isRecordedIn"),
                      value = NULL) {

  if (length(by) > 1) {
    message("Please select only one of 'type' or 'isRecordedIn' (using first)")
    by <- by[1]
  }
  if (is.null(value)) {
    stop("No value given for selection.")
  }

  idaifield_docs <- check_and_unnest(idaifield_docs)
  uid_type_list <- get_uid_list(idaifield_docs)

  col <- colnames(uid_type_list) == by

  typeindex <- which(uid_type_list[, col] %in% value)

  selected_docs <- idaifield_docs[typeindex]
  selected_docs <- structure(selected_docs, class = "idaifield_resources")

  return(selected_docs)
}
