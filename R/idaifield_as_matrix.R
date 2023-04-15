#' @title Convert an `idaifield_simple`-list to a Matrix
#'
#' @description Converts a list of class `idaifield_docs`, `idaifield_resource`
#' or `idaifield_simple` into a matrix. Recommended to use with
#' `idaifield_simple`-lists as returned by [simplify_idaifield()].
#' If given a list of class `idaifield_docs` containing all meta-info,
#' it will automatically unnest to resource level. It is recommended to
#' select the list first using [idf_select_by()] from this
#' package to reduce the amount of columns returned. See example.
#'
#' @param idaifield An object as returned by [get_idaifield_docs()],
#' [check_and_unnest()] or [simplify_idaifield()]
#'
#' @returns a matrix (depending on selection and project database
#' it can be very large)
#' @export
#'
#' @seealso
#' * [simplify_idaifield()]
#'
#'
#' 
#' 
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#'                                 user = "R",
#'                                 pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#'                                      projectname = "rtest")
#' pottery <- select_by(idaifield_docs, by = "category", value = "Pottery")
#' pottery <- simplify_idaifield(pottery,
#'                               uidlist = get_uid_list(idaifield_docs))
#' pottery <- idaifield_as_matrix(pottery)
#' }
idaifield_as_matrix <- function(idaifield) {

  resource_list <- suppressWarnings(check_and_unnest(idaifield))

  names_list <- lapply(resource_list, names)

  colnames <- unique(unlist(names_list))
  colnames <- reorder_colnames(colnames)
  nrow <- length(resource_list)
  ncol <- length(colnames)

  resource_matrix <- matrix(nrow = nrow,
                            ncol = ncol)

  colnames(resource_matrix) <- colnames


  for (listindex in seq_along(resource_list)) {
    single_resource <- resource_list[[listindex]]
    for (i in seq_along(single_resource)) {
      colindex <- match(names(single_resource)[i], colnames)
      content <- paste(unlist(single_resource[i]), collapse = "; ")
      resource_matrix[listindex, colindex] <- content
    }
  }

  return(resource_matrix)
}
