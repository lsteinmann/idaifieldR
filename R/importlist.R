#' show_type_list
#'
#' Returns a list of types present in the i.DAIfield 2-database
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
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' show_type_list(idaifield_docs)
#' }
show_type_list <- function(idaifield_docs) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  uid_type_list <- get_uid_list(idaifield_docs)
  db_types <- unique(uid_type_list$type)
  return(db_types)
}


#' select_by_type
#'
#' returns a subset of the docs list selected by type
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#' @param type Character expected, should be the internal Name of the Type
#' that will be selected for (e.g. "Layer", "Pottery")
#'
#' @return a list of class idaifield_resource containing the resources
#' which are of the selected type
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' idaifield_layers <- select_by_type(idaifield_docs, type = "Layer")
#' }
select_by_type <- function(idaifield_docs, type = "Pottery") {

  idaifield_docs <- check_and_unnest(idaifield_docs)
  uid_type_list <- get_uid_list(idaifield_docs)

  typeindex <- grep(type, uid_type_list$type)

  selected_docs <- idaifield_docs[typeindex]
  selected_docs <- structure(selected_docs, class = "idaifield_resource")

  return(selected_docs)
}
