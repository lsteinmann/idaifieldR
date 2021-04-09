#' na_if_empty: returns NA if an object handed to the function is empty
#'
#' This is a helper function in defense against empty list items from
#' i.DAIfield 2, which sometimes occur. It simply writes NA in the
#' corresponding field if a list or any kind of object handed to it is
#' of length 0. Otherwise, it returns the input untouched.
#'
#'
#' @param item any object whatsoever
#'
#' @return NA if empty, or the object that has been handed to it
#' @export
#'
#' @examples
#' na_if_empty(1)
#' na_if_empty(list(2,3,4,list(4,5,4)))
#' na_if_empty(NULL)
na_if_empty <- function(item) {
  if (length(item) == 0) {
    return(NA)
  } else {
    return(item)
  }
}




#' unnest_resource: Remove doc-level of idaifield_docs-List
#'
#' This function somewhat unnests the lists provided by i.DAIfield 2.
#' The actualy data of a resource is usually stored in a sub-list
#' behind $doc$resource, which contains the data one would mostly
#' want to work with in R.
#'
#' @param idaifield_docs A list as provided by sofa::db_alldocs(...), or
#' used within get_idaifield_docs(). The latter employs this function already,
#' so mostly there is no need to deal with it. If one chooses
#' get_idaifield_docs(..., simplified  = FALSE), it is possible to use
#' unnest_resource() later on in the resulting list to simplify it a later
#' point in time.
#' @param keep_geometry FALSE by default. TRUE if you wish to import the
#' geometry-fields into R (TODO: this is not reachable from top level function)
#'
#' @return a list of class idaifield_resource (same as idaifield_docs,
#' but the top-level with meta-information has been removed to make the actual
#' resource data more accessible)
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' simplified = FALSE,
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' idaifield_resources <- unnest_resource(idaifield_docs)
#' }
unnest_resource <- function(idaifield_docs, keep_geometry = FALSE) {

  check_result <- suppressMessages(check_if_idaifield(idaifield_docs))

  if (unname(check_result[1, "idaifield_docs"])) {
    for (i in seq_along(idaifield_docs)) {
      idaifield_docs[[i]] <- idaifield_docs[[i]]$doc$resource

      if (length(idaifield_docs[[i]]$relations) > 0) {
        new_relnames <- names(idaifield_docs[[i]]$relations)
        new_relnames <- paste("relations.", new_relnames, sep = "")
        names(idaifield_docs[[i]]$relations) <- new_relnames
        idaifield_docs[[i]] <- c(idaifield_docs[[i]],
                                 idaifield_docs[[i]]$relations)
        idaifield_docs[[i]]$relations <- NULL
      }
      if (!keep_geometry) {
        idaifield_docs[[i]]$geometry <- NULL
        idaifield_docs[[i]]$georeference <- NULL
      }
    }

    idaifield_docs <- structure(idaifield_docs, class = "idaifield_resource")
    return(idaifield_docs)

  } else if (unname(check_result[1, "idaifield_resource"])) {
    stop("The list is already unnested to resource-level.")
  } else {
    stop("The object provided cannot be processed by this function.")
  }
}




#' check_if_idaifield
#'
#' For internal use... checks if an object can actually processed by
#' the functions in this package which need the specific format that is
#' returned by the core function get_idaifield_docs(...).
#'
#' @param testobject An object that should be evaluated.
#'
#' @return a matrix that allows other functions to determine which type of
#' list the object is
#' @export
#'
#' @examples
#' check_if_idaifield(list(1,1,1,list(2,2,2)))
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' check_if_idaifield(idaifield_docs)
#' }
check_if_idaifield <- function(testobject) {

  result <- matrix(nrow = 1, ncol = 3)
  colnames(result) <- c("idaifield_docs", "idaifield_resource", "list")

  if (class(testobject) == "idaifield_docs") {
    message("The object provided is a docs-list as returned by ",
            "get_idaifield_docs(..., simplified = FALSE).")
    result[1, "idaifield_docs"] <- TRUE
  } else {
    result[1, "idaifield_docs"] <- FALSE
  }

  if (class(testobject) == "idaifield_resource") {
    message("The object provided is a resource-list as returned by ",
            "get_idaifield_docs(..., simplified = TRUE) or unnest_resource().")
    result[1, "idaifield_resource"] <- TRUE
  } else {
    result[1, "idaifield_resource"] <- FALSE
  }

  if (class(testobject) == "list") {
    message("The object is a list.")
    result[1, "list"] <- TRUE
  } else {
    result[1, "list"] <- FALSE
  }

  return(result)

  # --------------
  #' I didnt actually really want to create a class, as that might be
  #' horribly impractical, but it seemed the quickest way to get a structure
  #' check done without relying on too much poking.
  #' However, I don't really like it and am thinking about changing it again.
}



#' check_and_unnest
#'
#' Checks if the object is already unnested, and if it isnt, does so.
#' If it cant be processed, because it is not an idaifield_docs or
#' idaifield_resource object, throws error.
#'
#' @param idaifield_docs An object to be used by one of the
#' functions in this package
#'
#' @return if already unnested, the same object as handed to it. if not,
#' the same list with the toplevel removed.
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' check_and_unnest(idaifield_docs)
#' }
check_and_unnest <- function(idaifield_docs) {
  check <- suppressMessages(check_if_idaifield(idaifield_docs))
  if (unname(check[1, "idaifield_docs"])) {
    idaifield_docs <- unnest_resource(idaifield_docs)
    return(idaifield_docs)
  } else if (unname(check[1, "idaifield_resource"])) {
    return(idaifield_docs)
  } else {
    stop("Cannot process the object.")
  }
}



#' get_uid_list
#'
#' All resources from `idaifield` are refenced with their UID in the relations
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
#' idaifield_docs <- get_idaifield_docs(projectname = "testproj",
#' connection = connect_idaifield(serverip = "192.168.1.21",
#' user = "R",
#' pwd = "password"))
#'
#' uid_list <- get_uid_list(idaifield_docs, verbose = TRUE)
#' }
get_uid_list <- function(idaifield_docs, verbose = FALSE) {

  idaifield_docs <- check_and_unnest(idaifield_docs)

  if (verbose) {
    ncol <- 4
    colnames <- c("type", "UID", "identifier", "shortDescription")
  } else {
    ncol <- 3
    colnames <- c("type", "UID", "identifier")
  }
  uid_list <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uid_list) <- colnames
  for (i in seq_along(idaifield_docs)) {
    uid_list$UID[i] <- na_if_empty(idaifield_docs[[i]]$id)
    uid_list$type[i] <- na_if_empty(idaifield_docs[[i]]$type)
    uid_list$identifier[i] <- na_if_empty(idaifield_docs[[i]]$identifier)
    if (verbose) {
      short_description <- idaifield_docs[[i]]$shortDescription
      uid_list$shortDescription[i] <- na_if_empty(short_description)
    }
  }
  return(uid_list)
}



#' check_for_sublist
#'
#' Checks if a list has sublists and returns TRUE if so
#'
#' @param single_resource_field a list to be checked
#'
#' @return TRUE/FALSE
#' @export
#'
#' @examples
check_for_sublist <- function(single_resource_field) {
  if (class(single_resource_field) == "list") {
    len <- sapply(single_resource_field, length)
    len <- unname(len)
    if (length(len) == 1) {
      return(FALSE)
    } else if (length(len) > 1) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  } else {
    return(FALSE)
  }
}



#' check_if_uid
#'
#' @param string A character string that should be checked for being a UID
#' as used in i.DAIfield 2 (expects a single character value!)
#'
#' @return TRUE if UID, or FALSE if not
#' @export
#'
#' @examples
check_if_uid <- function(string) {
  if (length(string) != 1) {
    string <- string[1]
    # no one needs this warning?
    warning("check_if_string() has been given more than 1 string, only evaluating first.")
  }
  string <- as.character(string)
  is_uid <- grepl("\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", string)
  if (is_uid) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
