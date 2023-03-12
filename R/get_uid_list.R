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
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the fields, defaults to english ("en")
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
#' uidlist <- get_uid_list(idaifield_docs, verbose = TRUE)
#' }
get_uid_list <- function(idaifield_docs, verbose = FALSE,
                         gather_trenches = FALSE,
                         language = "en") {
  idaifield_docs <- check_and_unnest(idaifield_docs)

  ncol <- 5
  colnames <- c("type", "UID", "identifier", "isRecordedIn", "liesWithin")

  if (verbose) {
    ncol <- 7
    colnames <- c(colnames, "shortDescription", "liesWithinLayer")
  }


  uidlist <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uidlist) <- colnames

  uidlist$UID <- unlist(lapply(idaifield_docs,
                               FUN = function(x) na_if_empty(x$id)))

  uidlist$type <- unlist(lapply(idaifield_docs,
                                FUN = function(x) na_if_empty(x$type)))

  uidlist$type <- remove_config_names(uidlist$type)

  uidlist$identifier <- unlist(lapply(idaifield_docs,
                                      FUN = function(x) na_if_empty(x$identifier)))

  # have to check double for relations, as processed db resources are different
  # from the raw version
  uidlist$isRecordedIn <- unlist(lapply(idaifield_docs,
                                        function(x) na_if_empty(x$relations$isRecordedIn)))
  if (all(is.na(uidlist$isRecordedIn))) {
    uidlist$isRecordedIn <- unlist(lapply(idaifield_docs,
                                          function(x) na_if_empty(x$relation.isRecordedIn)))
  }
  uidlist$liesWithin <- unlist(lapply(idaifield_docs,
                                      function(x) na_if_empty(x$relations$liesWithin)))
  if (all(is.na(uidlist$liesWithin))) {
    uidlist$liesWithin <- unlist(lapply(idaifield_docs,
                                        function(x) na_if_empty(x$relation.liesWithin)))
  }

  if (verbose) {
    # get all entries for shortDescription
    desc <- lapply(idaifield_docs, function(x) na_if_empty(x$shortDescription))
    uidlist$shortDescription <- gather_languages(desc, language = language)
    uidlist$liesWithinLayer <- unlist(lapply(idaifield_docs,
                                             function(x) na_if_empty(x$relation.liesWithinLayer)))
  }

  uidlist$isRecordedIn <- replace_uid(uidlist$isRecordedIn, uidlist)
  uidlist$liesWithin <- replace_uid(uidlist$liesWithin, uidlist)

  if (gather_trenches) {

    gather_mat <- matrix(ncol = 3, nrow = nrow(uidlist))
    gather_mat[, 1] <- ifelse(is.na(uidlist$isRecordedIn),
                              uidlist$liesWithin,
                              uidlist$isRecordedIn)
    gather_mat[, 2] <- uidlist$type[match(gather_mat[, 1],
                                          uidlist$identifier)]
    gather_mat[, 3] <- uidlist$liesWithin[match(gather_mat[, 1],
                                                uidlist$identifier)]

    uidlist$Place <- ifelse(gather_mat[, 2] == "Trench",
                            gather_mat[, 3],
                            gather_mat[, 1])

  }

  return(uidlist)
}
