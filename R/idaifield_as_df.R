#' idaifield_as_df
#'
#' Converts the list that is returned by get_idaifield_docs(...) into a
#' data.frame with all columns present in the data. Individual rows will
#' contain NA if there was no information entered into the respective field
#' in `idaifield`. Lists are currently not preserved (e.g. the color-lists etc,
#' but instead converted to a ;-seperated character string). They can be pulled
#' apart again, and I am also thinking about preserving them in this
#' function (but have not done that yet.)
#'
#' If the list containing all meta-info (i.e. the docs-list)
#' is handed to the function it will automatically unnest to resource level).
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#'
#' @return a data.frame
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
#'
#' idaifield_df <- idaifield_as_df(idaifield_docs)
#' }
idaifield_as_df <- function(idaifield_docs) {

  resource_list <- check_and_unnest(idaifield_docs)

  names_list <- sapply(resource_list, names)

  colnames <- unique(unlist(names_list))

  resource_simple <- as.data.frame(matrix(nrow = length(resource_list),
                                          ncol = length(colnames)))
  colnames(resource_simple) <- colnames

  for (listindex in seq_len(length(resource_list))) {
    sublist <- resource_list[[listindex]]
    for (i in seq_len(length(sublist))) {
      colindex <- match(names(sublist)[i], colnames)
      if (class(sublist[[i]]) == "list") {
        pasted_info <- paste(names(sublist[[i]]), unlist(sublist[[i]]),
                             collapse = "; ")
        resource_simple[listindex, colindex] <- pasted_info
      } else {
        resource_simple[listindex, colindex] <- sublist[[i]]
      }
    }
  }

  return(resource_simple)
}
