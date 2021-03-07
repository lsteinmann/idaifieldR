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
#' \dontrun{
#' check_if_idaifield(list(1, 1, 1, list(2, 2, 2)))
#'
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
  # I didnt actually really want to create a class, as that might be
  # horribly impractical, but it seemed the quickest way to get a structure
  # check done without relying on too much poking.
  # However, I don't really like it and am thinking about changing it again.
}



#' Check and unnest a list
#'
#' Checks for list of class "idaifield_docs" and if the object is already
#' unnested (i.e. of class "idaifield_resources"); if it is not, does so.
#' If it cannot be processed, because it is not an idaifield_docs or
#' idaifield_resources object, throws error.
#' TODO: wrap in trycatch to process anyway if possible
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
#' list <- list(1, 2, 3, list("börek", 2, 3))
#'
#' check_for_sublist(list)
check_for_sublist <- function(single_resource_field) {
  if (is.list(single_resource_field)) {
    sublists <- vapply(single_resource_field,
                       function(x) is.list(x),
                       FUN.VALUE = logical(1))
    has_sublist <- any(sublists)
  } else {
    warning("Object is not a list.")
    has_sublist <- FALSE
  }
  return(has_sublist)
}



#' check_if_uid
#'
#' @param string A character string that should be checked for being a UID
#' as used in i.DAIfield 2 (expects a single character value!)
#' TODO: any() with grepl and then blaaaa
#'
#' @return TRUE if UID, or FALSE if not
#' @export
#'
#' @examples
#'
#' check_if_uid(string = "0324141a-8201-c5dc-631b-4dded4552ac4")
#' check_if_uid(string = "not a uid")
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



#' Reorders the column names for idaifield_as_matrix()
#'
#' @param colnames a character vector with colnames
#' @param order either "default" for default order (first columns are
#' "identifier", "type", "shortDescription" and the rest is as assembled) or
#' a character vector with exact column names that will then place these as
#' the first n columns of the matrix produced by idaifield_as_matrix()
#'
#' @return a character vector
#' @export
#'
#' @examples
#'
#' colnames <- c("materialType", "identifier", "shortDescription", "type")
#'
#' reorder_colnames(colnames, order = "default")
#'
reorder_colnames <- function(colnames, order = "default") {
  if (order == "default") {
    order <- c("identifier", "type", "shortDescription")
  }
  new_order <- match(order, colnames)
  new_order <- new_order[!is.na(new_order)]
  not_ordered <- colnames[-new_order]
  new_order <- colnames[new_order]
  colnames <- c(new_order, not_ordered)
  return(colnames)
}
