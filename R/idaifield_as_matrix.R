#' idaifield_as_matrix
#'
#' Converts an idaifield_docs/idaifield_resource-list into a Matrix.
#'
#' If the list containing all meta-info (i.e. the docs-list)
#' is handed to the function it will automatically unnest and simplify if
#' necessary to resource level).
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs(...)

#'
#' @return a matrix (depending on selection and database it can be very large)
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest", simplified = TRUE)
#'
#' idaifield_mat <- idaifield_as_matrix(idaifield_docs)
#' }
idaifield_as_matrix <- function(idaifield_docs) {

  resource_list <- check_and_unnest(idaifield_docs)

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




