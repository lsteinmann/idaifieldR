#' na_if_empty: returns NA if an object handed to the function is empty
#'
#' This is a helper function in defense against empty list items from
#' iDAI.field 2 / Field Desktop, which sometimes occur.
#' It simply writes NA in the corresponding field if a list or any
#' kind of object handed to it is of length 0. Otherwise,
#' it returns the input untouched.
#'
#'
#' @param item any object whatsoever
#'
#' @keywords internal
#'
#' @return NA if empty, or the object that has been handed to it
#'
#' @examples
#' \dontrun{
#' na_if_empty(1)
#' na_if_empty(list(2,3,4,list(4,5,4)))
#' na_if_empty(NULL)
#' }
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
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(projectname = "rtest",
#' connection = connect_idaifield(serverip = "127.0.0.1",
#' user = "R",
#' pwd = "password"))
#'
#' check_if_idaifield(idaifield_docs)
#' }
check_if_idaifield <- function(testobject) {

  result <- rep(NA, 4)
  names(result) <- c("idaifield_docs", "idaifield_resources",
                     "idaifield_simple", "list")

  if (inherits(testobject, "idaifield_docs")) {
    result["idaifield_docs"] <- TRUE
  } else {
    result["idaifield_docs"] <- FALSE
  }

  if (inherits(testobject, "idaifield_resources")) {
    result["idaifield_resources"] <- TRUE
  } else {
    result["idaifield_resources"] <- FALSE
  }

  if (inherits(testobject, "idaifield_simple")) {
    result["idaifield_simple"] <- TRUE
  } else {
    result["idaifield_simple"] <- FALSE
  }

  if (inherits(testobject, "list")) {
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

#' check_for_sublist
#'
#' Checks if a list has sublists and returns TRUE if so
#'
#' # TODO absolutely stupid
#'
#' @param single_resource_field a list to be checked
#'
#' @return TRUE/FALSE
#'
#' @keywords internal
#'
#'
#' @examples
#' \dontrun{
#' list <- list(1, 2, 3, list("börek", 2, 3))
#'
#' check_for_sublist(list)
#' }
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
#' @param string A character string or vector of character strings that should
#' be checked for being a UID as used in iDAI.field 2 / Field Desktop
#'
#' @return a vector of the same length as string containing TRUE if
#' the corresponding item in string is a UID, FALSE if not
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' check_if_uid(string = "0324141a-8201-c5dc-631b-4dded4552ac4")
#' check_if_uid(string = "not a uid")
#' }
check_if_uid <- function(string) {
  is_uid <- grepl("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", string)
  return(is_uid)
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
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' colnames <- c("materialType", "identifier", "shortDescription", "type")
#'
#' reorder_colnames(colnames, order = "default")
#' }
reorder_colnames <- function(colnames, order = "default") {
  if (order == "default") {
    order <- c("identifier", "type", "shortDescription",
               "processor", "campaign", "relation.isRecordedIn")
  }
  new_order <- match(order, colnames)
  new_order <- new_order[!is.na(new_order)]
  not_ordered <- colnames[-new_order]
  not_ordered <- sort(not_ordered)
  new_order <- colnames[new_order]
  colnames <- c(new_order, not_ordered)
  return(colnames)
}



#' Gather multilanguage fields
#'
#' @param input_list a list with character values containing (or not)
#' sublists for each language
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the fields, defaults to english ("en")
#' @param silant TRUE/FALSE: Should gather_languages()
#' issue messages and warnings?
#'
#' @return a vector containing the values
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' input_list <- list(list("en" = "English text", "de" = "Deutscher Text"),
#'                    list("en" = "Another english text", "de" = "Weiterer dt. Text"))
#' gather_languages(input_list, language = "de")
#' }
gather_languages <- function(input_list, language = "en", silent = FALSE) {
  # if this has a sublist / more than one entry, it means that there is
  # more than one language
  if (check_for_sublist(input_list)) {
    # try to get the selected language or english
    res <- lapply(input_list, function(x) na_if_empty(unlist(x[language])))
    res <- unlist(res)
    if (all(is.na(res))) {
      if (!silent) {
        # issue warning is this does not work
        warning("No language selected or selected language not available, using first entry")
      }
      # instead get the first entry
      res <- unlist(lapply(input_list, function(x) x[1]))
    }
    if (any(is.na(res))) {
      # if there are still NA-values, assume that sometimes people only filled
      # in one language and loop through all languages to fill the NA values
      languages <- sort(unique(unlist(lapply(input_list,
                                             function(x) names(x)))))
      for (i in seq_along(languages)) {
        res_sec <- lapply(input_list, function(x) na_if_empty(unlist(x[languages[i]])))
        res_sec <- unlist(res_sec)
        res <- ifelse(is.na(res), res_sec, res)
        no_list_ind <- unlist(lapply(input_list, is.character))
        no_list_ind <- which(no_list_ind)
        res[no_list_ind] <- unlist(input_list)[no_list_ind]
      }
    }
  } else {
    res <- unlist(lapply(input_list, function(x) na_if_empty(x)))
  }
  # remove the names
  res <- unname(res)
  return(res)
}


