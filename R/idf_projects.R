#' Get a vector of project names present in the database
#'
#' @param connection The connection settings as
#' returned by `connect_idaifield()`
#'
#' @return A character vector containing the projects present in the database,
#' NA if connection was refused.
#' @export
#'
#' @examples
#' \dontrun{
#'  connection <- connect_idaifield(pwd = "hallo")
#'  idf_project_list(connection)
#' }
idf_projects <- function(connection) {
  if (connection$status) {
    url <- paste0(connection$settings$base_url, "/_all_dbs")
    client <- crul::HttpClient$new(url = url,
                                   opts = connection$settings$auth,
                                   headers = connection$settings$headers)

    result <- response_to_list(client$get())
    result <- unlist(result)

    repl <- which(result == "_replicator")
    if (length(repl) != 0) {
      result <- result[-repl]
    }
    return(result)
  } else {
    stop("Could not connect to database. Check the connection settings.")
  }
}





