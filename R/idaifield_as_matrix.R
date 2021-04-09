#' idaifield_as_matrix
#'
#' Converts an idaifield_docs/idaifield_resource-list into a Matrix that
#' contains lists where multiple selections have been made in i.DAIfield 2,
#' which can be more flexible than the dataframe-approach in idaifield_as_df.
#'
#' If the list containing all meta-info (i.e. the docs-list)
#' is handed to the function it will automatically unnest to resource level).
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)
#'
#' @return a matrix (depending on selection and database it can be very large)
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' idaifield_mat <- idaifield_as_matrix(idaifield_docs)
#' }
idaifield_as_matrix <- function(idaifield_docs) {

  resource_list <- check_and_unnest(idaifield_docs)
  uidlist <- get_uid_list(idaifield_docs = idaifield_docs)

  names_list <- lapply(resource_list, names)

  colnames <- unique(unlist(names_list))
  colnames <- reorder_colnames(colnames)
  nrow <- length(resource_list)
  ncol <- length(colnames)
  resource_matrix <- matrix(rep(list(), nrow * ncol),
                            nrow = nrow,
                            ncol = ncol)
  colnames(resource_matrix) <- colnames

  for (listindex in seq_along(resource_list)) {
    single_resource <- resource_list[[listindex]]
    for (i in seq_along(single_resource)) {
      colindex <- match(names(single_resource)[i], colnames)
      resource_matrix[listindex, colindex] <- single_resource[i]
    }
  }
  null_vec <- which(lapply(resource_matrix, length) == 0)
  resource_matrix[null_vec] <- NA
  return(resource_matrix)
}
