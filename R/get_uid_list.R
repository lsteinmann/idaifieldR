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
#' connection <- connect_idaifield(serverip = "192.168.2.21",
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
    ncol <- 6
    colnames <- c(colnames, "shortDescription")
  }

  uid_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_list) <- colnames
  for (i in seq_along(idaifield_docs)) {
    uid_list$UID[i] <- na_if_empty(idaifield_docs[[i]]$id)
    uid_list$type[i] <- na_if_empty(idaifield_docs[[i]]$type)
    uid_list$identifier[i] <- na_if_empty(idaifield_docs[[i]]$identifier)

    isRecordedIn <- unlist(idaifield_docs[[i]]$relations$isRecordedIn)
    if (is.null(isRecordedIn)) {
      isRecordedIn <- unlist(idaifield_docs[[i]]$relation.isRecordedIn)
    }
    uid_list$isRecordedIn[i] <- na_if_empty(isRecordedIn)

    liesWithin <- unlist(idaifield_docs[[i]]$relations$liesWithin)
    if (is.null(liesWithin)) {
      liesWithin <- unlist(idaifield_docs[[i]]$relation.liesWithin)
    }
    uid_list$liesWithin[i] <- na_if_empty(liesWithin)

    if (verbose) {
      short_description <- idaifield_docs[[i]]$shortDescription
      uid_list$shortDescription[i] <- na_if_empty(short_description)
    }
  }

  uid_list$isRecordedIn <- replace_uid(uid_list$isRecordedIn, uid_list)
  uid_list$liesWithin <- replace_uid(uid_list$liesWithin, uid_list)

  if (gather_trenches) {
    uid_list$Place <- uid_list$isRecordedIn
    for (i in seq_len(nrow(uid_list))) {
      temp_place <- uid_list$Place[i]
      temp_place <- which(uid_list$identifier == temp_place)
      temp_place <- uid_list[temp_place,]

      if (nrow(temp_place) == 0) {
        next
      } else if (temp_place$type == "Trench") {
        uid_list$Place[i] <- temp_place$liesWithin[1]
      }
    }
  }


  return(uid_list)
}
