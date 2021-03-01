#' Returns NA if an objects is empty
#'
#' (defense against empty list items from idaifield)
#' does basically nothing, just checking if input is of length 0 and if so
#' returning NA, if not returning the input untouched.
#'
#' @param item can be anything.
#'
#' @return
#' @export
#'
#' @examples
ifnotempty <- function(item) {
  if (length(item) == 0) {
    return(NA)
  } else {
    return(item)
  }
}




#' removes the top layers of the json-list since they are not needed
#'
#' @param idaifield_docs
#'
#' @return
#' @export
#'
#' @examples
unnest_resource <- function(idaifield_docs) {

  for (i in 1:length(idaifield_docs)) {
    idaifield_docs[[i]] <- idaifield_docs[[i]]$doc$resource
    idaifield_docs[[i]] <- c(idaifield_docs[[i]], unlist(idaifield_docs[[i]]$relations))
  }

  return(idaifield_docs)
}



