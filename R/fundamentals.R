#' get_idaifield_connection
#'
#' connects to the idaifield-database running on the serverip, is a shorter wrapper for sofa's Cushion$new
#' with defaults for idaifield. people still need to enter the serverip, arbitrary username and password.
#'
#' @param serverip
#' @param user
#' @param pwd
#' @param projectname
#'
#' @return connection object
#' @export get_idaifield_connection
#'
#' @examples
get_idaifield_connection <- function(serverip = "192.168.1.199",
                                     user = "Anna Allgemeinperson",
                                     pwd = "password"){
  idaifield_connection <- sofa::Cushion$new(host = serverip,
                                            transport = "http",
                                            port = 3000,
                                            user = user,
                                            pwd = pwd)
  return(idaifield_connection)
}


#' get_idaifield_docs
#'
#' Imports the docs from an idaifield-database that is currently running and synching, needs a connection-object
#' as produced by sofa directly or with get_idaifield_connection()
#'
#' @param idaifield_connection
#' @param projectname
#' @param all
#'
#' @return
#' @export
#'
#' @examples
get_idaifield_docs <- function(idaifield_connection = get_idaifield_connection(),
                               projectname = "projektname",
                               all = TRUE) {
  sofa::db_info(idaifield_connection, projectname)
  idaifield_docs <- sofa::db_alldocs(idaifield_connection, projectname, include_docs = TRUE)$rows
  return(idaifield_docs)
}




#' get_uid_type_list
#'
#' gets a list of UIDs and Type for selecting later on
#'
#' @param idaifield_docs
#' @param verbose TRUE or FALSE, TRUE returns a list including identifier and shorttitle which is more convenient for humans, and FALSE returns only UID and type, which is enough for internal selections
#'
#' @return
#' @export
#'
#' @examples
get_uid_type_list <- function(idaifield_docs, verbose = FALSE){
  if (verbose) {
    ncol <- 4
    colnames <- c("uid", "identifier", "shorttitle", "type")
  } else {
    ncol = 2
    colnames <- c("uid", "type")
  }
  uid_type_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_type_list) <- colnames
  for (i in 1:length(idaifield_docs)){
    uid_type_list$uid[i] <- idaifield_docs[[i]]$key
    uid_type_list$type[i] <- idaifield_docs[[i]]$doc$resource$type
    if (verbose) {
      uid_type_list$identifier[i] <- idaifield_docs[[i]]$doc$resource$identifier
      uid_type_list$shorttitle[i] <- ifnotempty(idaifield_docs[[i]]$doc$resource$shortDescription)
    }
  }
  return(uid_type_list)
}
