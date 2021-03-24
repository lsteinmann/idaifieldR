#' get_uid_list
#'
#' All resources from `idaifield` are referenced with their UID in the relations
#' fields. Therefore, for many purposes a lookup-table needs to be provided
#' in order to get to the actual identifiers and names of the resources
#' referenced.
#'
#' This function is also good for a quick overview / a list of all the
#' resources that exist along with their identifiers and short descriptions
#' and can be used to select the resources along their respective Types
#' (e.g. Pottery, Layer etc.). Please note that in any case the internal
#' names of everything will be used. If you relabeled `Trench` to `Schnitt` in
#' your language-configuration, this will still be `Trench` here.
#' None of these functions have any respect for language configuration!
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs
#' @param verbose TRUE or FALSE (= anything but TRUE), TRUE returns a list
#' including identifier and shorttitle which is more convenient for humans,
#' and FALSE returns only UID and type, which is enough for internal selections
#'
#' @return a list of UIDs and their Types, Identifiers and shortDescriptions
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
#'
#' uid_list <- get_uid_list(idaifield_docs, verbose = TRUE)
#' }
get_uid_list <- function(idaifield_docs, verbose = FALSE) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  ncol <- 4
  colnames <- c("type", "UID", "identifier", "isRecordedIn")

  if (verbose) {
    ncol <- 5
    colnames <- c(colnames, "shortDescription")
  }

  uid_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_list) <- colnames
  for (i in seq_along(idaifield_docs)) {
    uid_list$UID[i] <- na_if_empty(idaifield_docs[[i]]$id)
    uid_list$type[i] <- na_if_empty(idaifield_docs[[i]]$type)
    uid_list$identifier[i] <- na_if_empty(idaifield_docs[[i]]$identifier)
    isRecordedIn <- unlist(idaifield_docs[[i]]$relations$isRecordedIn)
    uid_list$isRecordedIn[i] <- na_if_empty(isRecordedIn)
    if (verbose) {
      short_description <- idaifield_docs[[i]]$shortDescription
      uid_list$shortDescription[i] <- na_if_empty(short_description)
    }
  }

  uid_list$isRecordedIn <- replace_uid(uid_list$isRecordedIn, uid_list)
  return(uid_list)
}
