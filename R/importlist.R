#' show_type_list
#'
#' returns a list of types present in the idaifield-database (for orientation)
#' it would be nice to be able to embed the translations, but i am guessing thats only
#' possible if the configuration was available
#'
#' @param idaifield_docs
#'
#' @return
#' @export
#'
#' @examples
show_type_list <- function(idaifield_docs) {
  uid_type_list <- get_uid_type_list(idaifield_docs)
  db_types <- unique(uid_type_list$type)
  return(db_types)
}


#' select_by_type
#'
#' returns a subset of the docs list selected by type
#'
#' @param idaifield_docs
#' @param type
#'
#' @return
#' @export
#'
#' @examples
select_by_type <- function(idaifield_docs, type = "Pottery") {

  uid_type_list <- get_uid_type_list(idaifield_docs)
  typeindex <- grep(type, uid_type_list$type)

  selected_docs <- idaifield_docs[typeindex]
  selected_docs <- unnest_resource(selected_docs)
  return(selected_docs)
}



#' Tries to convert the list that one gets from the json-format into a usable df
#' this is currently horrible
#'
#' @param idaifield_docs
#'
#' @return
#' @export
#'
#' @examples
convert_to_df <- function(idaifield_docs) {

  if (length(idaifield_docs[[1]]$doc$resource) == 0) {
    resource_list <- idaifield_docs
  } else {
    resource_list <- unnest_resource(idaifield_docs)
  }

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





