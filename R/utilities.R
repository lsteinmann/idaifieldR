#' na_if_empty: returns NA if an object handed to the function is empty
#'
#' This is a helper function in defense against empty list items from `idaifield`,
#' which sometimes occur. It simply writes NA in the corresponding field if a
#' list or any kind of object handed to it is of length 0.
#' Otherwise, it returns the input untouched.
#'
#'
#' @param item any object whatsoever
#'
#' @return
#' @export
#'
#' @examples
na_if_empty <- function(item) {
  if (length(item) == 0) {
    return(NA)
  } else {
    return(item)
  }
}




#' unnest_resource: Remove doc-level of `idaifield`-List
#'
#' This function somewhat unnests the lists provided by `idaifield`. The actualy data
#' of a resource is usually stored in a sub-list behind $doc$resource, which contains
#' the data one would mostly want to work with in R.
#'
#' @param idaifield_docs A list as provided by sofa::db_alldocs(...), or used within
#' get_idaifield_docs(). The latter employs this function already, so mostly there is no
#' need to deal with it. If one chooses get_idaifield_docs(..., simplified  = FALSE), it is
#' possible to use unnest_resource() later on in the resulting list to simplify it a later
#' point in time.
#'
#' @return
#' @export
#'
#' @examples
unnest_resource <- function(idaifield_docs) {

  check_result <- suppressMessages(check_if_idaifield(idaifield_docs))

  if (unname(check_result[1,"idaifield_docs"])) {
    for (i in 1:length(idaifield_docs)) {
      idaifield_docs[[i]] <- idaifield_docs[[i]]$doc$resource
      idaifield_docs[[i]] <- c(idaifield_docs[[i]], unlist(idaifield_docs[[i]]$relations))
    }

    idaifield_docs <- structure(idaifield_docs, class = "idaifield_resource")
    return(idaifield_docs)

  } else if (unname(check_result[1,"idaifield_resource"])) {
    stop("The list is already unnested to resource-level.")
  } else {
    stop("The object provided cannot be processed by this function.")
  }
}




#' check_if_idaifield
#'
#' For internal use... checks if an object can actually processed by the functions
#' in this package which need the specific format that is returned by the core
#' function get_idaifield_docs(...).
#'
#' @param testobject An object that should be evaluated.
#'
#' @return
#' @export
#'
#' @examples
check_if_idaifield <- function(testobject) {

  result <- matrix(nrow = 1, ncol = 3)
  colnames(result) <- c("idaifield_docs", "idaifield_resource", "list")

  if (class(testobject) == "idaifield_docs") {
    message("The object provided is a docs-list as returned by get_idaifield_docs(..., simplified = FALSE).")
    result[1,"idaifield_docs"] <- TRUE
  } else {
    result[1,"idaifield_docs"] <- FALSE
  }

  if (class(testobject) == "idaifield_resource") {
    message("The object provided is a resource-list as returned by get_idaifield_docs(..., simplified = TRUE) or unnest_resource().")
    result[1,"idaifield_resource"] <- TRUE
  } else {
    result[1,"idaifield_resource"] <- FALSE
  }

  if (class(testobject) == "list") {
    message("The object is a list.")
    result[1,"list"] <- TRUE
  } else {
    result[1,"list"] <- FALSE
  }

  return(result)

  # --------------
  #' I didnt actually really want to create a class, as that might be horribly impractical,
  #' but it seemed the quickest way to get a structure check done without relying on too much
  #' poking.
  #' However, I don't really like it and am thinking about changing it again.
}



#' check_and_unnest
#'
#' Checks if the object is already unnested, and if it isnt, does so. If it cant
#' be processed, because it is not an idaifield_docs or idaifield_resource object,
#' throws error.
#'
#' @param idaifield_docs An object to be used by one of the functions in this package
#'
#' @return
#' @export
#'
#' @examples
check_and_unnest <- function(idaifield_docs) {
  check <- suppressMessages(check_if_idaifield(idaifield_docs))
  if (unname(check[1,"idaifield_docs"])) {
    idaifield_docs <- unnest_resource(idaifield_docs)
    return(idaifield_docs)
  } else if (unname(check[1,"idaifield_resource"])) {
    return(idaifield_docs)
  } else {
    stop("Cannot process the object.")
  }
}



#' get_uid_list
#'
#' All resources from `idaifield` are refenced with their UID in the relations fields. Therefore, for many purposes
#' a lookup-table needs to be provided in order to get to the actual identifiers and names of the resources referenced.
#'
#' This function is also good for a quick overview / a list of all the resources that exist along with their identifiers
#' and short descriptions and can be used to select the resources along their respective Types (e.g. Pottery, Layer etc.).
#' Please note that in any case the internal names of everything will be used. If you relabeled `Trench` to `Schnitt` in
#' your language-configuration, this will still be `Trench` here. None of these functions have any respect for language
#' configuration!
#'
#' @param idaifield_docs An object as returned by get_idaifield_docs
#' @param verbose TRUE or FALSE (= anything but TRUE), TRUE returns a list including identifier and shorttitle which is
#' more convenient for humans, and FALSE returns only UID and type, which is enough for internal selections
#'
#' @return
#' @export
#'
#' @examples
get_uid_list <- function(idaifield_docs, verbose = FALSE){

  idaifield_docs <- check_and_unnest(idaifield_docs)

  if (verbose) {
    ncol <- 4
    colnames <- c("type", "UID", "identifier", "shorttitle")
  } else {
    ncol = 3
    colnames <- c("type", "UID", "identifier")
  }
  uid_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_list) <- colnames
  for (i in 1:length(idaifield_docs)){
    uid_list$UID[i] <- na_if_empty(idaifield_docs[[i]]$id)
    uid_list$type[i] <- na_if_empty(idaifield_docs[[i]]$type)
    uid_list$identifier[i] <- na_if_empty(idaifield_docs[[i]]$identifier)
    if (verbose) {
      uid_list$shorttitle[i] <- na_if_empty(idaifield_docs[[i]]$shortDescription)
    }
  }
  return(uid_list)
}


