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
#' @param gather_trenches defaults to FALSE. If TRUE, adds another column that
#' records the Place each corresponding Trench and its sub-resources lie within.
#' (Useful for grouping the finds of several trenches.)
#'
#' @return a list of UIDs and their Types, Identifiers and shortDescriptions
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#' projectname = "rtest", simplified = FALSE)
#'
#' uid_list <- get_uid_list(idaifield_docs, verbose = TRUE)
#' }
get_uid_list <- function(idaifield_docs, verbose = FALSE,
                         gather_trenches = FALSE) {
  idaifield_docs <- check_and_unnest(idaifield_docs)

  ncol <- 5
  colnames <- c("type", "UID", "identifier", "isRecordedIn", "liesWithin")

  if (verbose) {
    ncol <- 7
    colnames <- c(colnames, "shortDescription", "liesWithinLayer")
  }

  uid_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_list) <- colnames

  uid_list$UID <- unlist(lapply(idaifield_docs,
                                FUN = function(x) na_if_empty(x$id)))

  uid_list$type <- unlist(lapply(idaifield_docs,
                                 FUN = function(x) na_if_empty(x$type)))

  uid_list$identifier <- unlist(lapply(idaifield_docs,
                                       FUN = function(x) na_if_empty(x$identifier)))

  # have to check double for relations, as processed db resources are different
  # from the raw version
  uid_list$isRecordedIn <- unlist(lapply(idaifield_docs,
                                         function(x) na_if_empty(x$relations$isRecordedIn)))
  if (all(is.na(uid_list$isRecordedIn))) {
    uid_list$isRecordedIn <- unlist(lapply(idaifield_docs,
                                           function(x) na_if_empty(x$relation.isRecordedIn)))
  }
  uid_list$liesWithin <- unlist(lapply(idaifield_docs,
                                       function(x) na_if_empty(x$relations$liesWithin)))
  if (all(is.na(uid_list$liesWithin))) {
    uid_list$liesWithin <- unlist(lapply(idaifield_docs,
                                         function(x) na_if_empty(x$relation.liesWithin)))
  }


  if (verbose) {
    uid_list$shortDescription <- unlist(lapply(idaifield_docs,
                                               function(x) na_if_empty(x$shortDescription)))
    uid_list$liesWithinLayer <- unlist(lapply(idaifield_docs,
                                              function(x) na_if_empty(x$relation.liesWithinLayer)))
  }

  uid_list$isRecordedIn <- replace_uid(which(colnames(uid_list) == "isRecordedIn"), uid_list)
  uid_list$liesWithin <- replace_uid(which(colnames(uid_list) == "liesWithin"), uid_list)

  if (gather_trenches) {

    gather_mat <- matrix(ncol = 3, nrow = nrow(uid_list))
    gather_mat[,1] <- ifelse(is.na(uid_list$isRecordedIn),
                             uid_list$liesWithin,
                             uid_list$isRecordedIn)
    gather_mat[,2] <- uid_list$type[match(gather_mat[,1],
                                          uid_list$identifier)]
    gather_mat[,3] <- uid_list$liesWithin[match(gather_mat[,1],
                                          uid_list$identifier)]

    uid_list$Place <- ifelse(gather_mat[,2] == "Trench",
                             gather_mat[,3],
                             gather_mat[,1])

  }

  return(uid_list)
}
