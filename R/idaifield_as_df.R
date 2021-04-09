#' idaifield_as_df
#'
#' Converts the list that is returned by get_idaifield_docs(...) into a
#' data.frame with all columns present in the data. Individual rows will
#' contain NA if there was no information entered into the respective field
#' in iDAI.field 2. Lists are currently not preserved (e.g. the color-lists etc,
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
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' idaifield_df <- idaifield_as_df(idaifield_docs)
#' }
idaifield_as_df <- function(idaifield_docs) {

  resource_list <- check_and_unnest(idaifield_docs)

  names_list <- lapply(resource_list, names)

  colnames <- unique(unlist(names_list))

  resource_simple <- as.data.frame(matrix(nrow = length(resource_list),
                                          ncol = length(colnames)))
  colnames(resource_simple) <- colnames

  for (listindex in seq_along(resource_list)) {
    single_resource <- resource_list[[listindex]]
    for (i in seq_along(single_resource)) {
      colindex <- match(names(single_resource)[i], colnames)
      if (class(single_resource[[i]]) == "list") {
        pasted_info <- paste(names(single_resource[[i]]),
                             unlist(single_resource[[i]]),
                             collapse = "; ")
        resource_simple[listindex, colindex] <- pasted_info
      } else {
        resource_simple[listindex, colindex] <- single_resource[[i]]
      }
    }
  }

  return(resource_simple)
}
