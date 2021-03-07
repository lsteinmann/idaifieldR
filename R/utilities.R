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
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
#'
#' check_if_idaifield(idaifield_docs)
#' }
check_if_idaifield <- function(testobject) {

  result <- rep(NA, 3)
  names(result) <- c("idaifield_docs", "idaifield_resources", "list")

  if (class(testobject) == "idaifield_docs") {
    result["idaifield_docs"] <- TRUE
  } else {
    result["idaifield_docs"] <- FALSE
  }

  if (class(testobject) == "idaifield_resources") {
    result["idaifield_resources"] <- TRUE
  } else {
    result["idaifield_resources"] <- FALSE
  }

  if (class(testobject) == "list") {
    result["list"] <- TRUE
  } else {
    result["list"] <- FALSE
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
#' idaifield_resources object, throws error.
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
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
#'
#' check_and_unnest(idaifield_docs)
#' }
check_and_unnest <- function(idaifield_docs) {
  check <- check_if_idaifield(idaifield_docs)
  if (check["idaifield_docs"]) {
    idaifield_docs <- unnest_resource(idaifield_docs)
    return(idaifield_docs)
  } else if (check["idaifield_resources"]) {
    return(idaifield_docs)
  } else {
    stop("Cannot process the object.")
  }
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
