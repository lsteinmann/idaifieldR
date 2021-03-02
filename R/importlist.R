#' show_type_list
#'
#' Returns a list of types present in the idaifield-database (for orientation)
#' it would be nice to be able to embed the translations, but i am guessing thats only
#' possible if the configuration was available
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...); unnests to
#' resource level if it didn't already happen.
#'
#' @return
#' @export
#'
#' @examples
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
#' @param type Character expected, should be the internal Name of the Type that will be selected for (e.g. "Layer", "Pottery")
#'
#' @return
#' @export
#'
#' @examples
select_by_type <- function(idaifield_docs, type = "Pottery") {

  idaifield_docs <- check_and_unnest(idaifield_docs)
  uid_type_list <- get_uid_list(idaifield_docs)

  typeindex <- grep(type, uid_type_list$type)

  selected_docs <- idaifield_docs[typeindex]
  selected_docs <- structure(selected_docs, class = "idaifield_resource")

  return(selected_docs)
}



#' idaifield_as_df
#'
#' Converts the list that is returned by get_idaifield_docs(...) into a data.frame with
#' all columns present in the data. Individual rows will contain NA if there was no information
#' entered into the respective field in `idaifield`. Lists are currently not preserved (e.g.
#' the color-lists etc, but instead converted to a ;-seperated character string). They can be
#' pulled apart again, and I am also thinking about preserving them in this function (but have not
#' done that yet.)
#'
#' If the list containing all meta-info (i.e. the docs-list)
#' is handed to the function it will automatically unnest to resource level).
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#'
#' @return
#' @export
#'
#' @examples
idaifield_as_df <- function(idaifield_docs) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  names_list <- sapply(resource_list, names)

  colnames <- unique(unlist(names_list))

  resource_simple <- as.data.frame(matrix(nrow = length(resource_list), ncol = length(colnames)))
  colnames(resource_simple) <- c(colnames, "liesWithin", "isRecordedIn")

  for (listindex in 1:length(resource_list)) {
    sublist <- resource_list[[listindex]]
    for (i in 1:length(sublist)) {
      colindex <- match(names(sublist)[i], colnames)
      if (class(sublist[[i]]) == "list") {
        pasted_info <- paste(names(sublist[[i]]), unlist(sublist[[i]]), collapse = "; ")
        resource_simple[listindex,colindex] <- pasted_info
      } else {
        resource_simple[listindex,colindex] <- sublist[[i]]
      }
    }
  }

  return(resource_simple)
}





