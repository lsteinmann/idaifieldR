#' Returns NA if an object handed to the function is empty
#'
#' This is a helper function in defence against empty list items from
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
#' @returns NA if empty, or the object that has been handed to it
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

#' Check for `idaifield_...` classes
#'
#' For internal use... checks if an object can actually processed by
#' the functions in this package which need the specific format that is
#' returned by the core function get_idaifield_docs(...).
#'
#' @param testobject An object that should be evaluated.
#'
#' @returns a matrix that allows other functions to determine which type of
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
}

#' Checks if a list has sub-lists and returns TRUE if so
#'
#'
#' @param single_resource_field a list to be checked
#'
#' @returns TRUE/FALSE
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
    has_sublist <- FALSE
  }
  return(has_sublist)
}

#' Check if the vector/object is a UUID
#'
#' @param string A character string or vector of character strings that should
#' be checked for being a UID as used in iDAI.field 2 / Field Desktop
#'
#' @returns a vector of the same length as string containing TRUE if
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
#' "identifier", "category", "shortDescription" and the rest is as assembled) or
#' a character vector with exact column names that will then place these as
#' the first n columns of the matrix produced by idaifield_as_matrix()
#'
#' @returns a character vector
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' colnames <- c("materialType", "identifier", "shortDescription", "category")
#'
#' reorder_colnames(colnames, order = "default")
#' }
reorder_colnames <- function(colnames, order = "default") {
  if (order == "default") {
    order <- c("identifier", "category", "shortDescription",
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


#' Format the response of a crul::HttpClient from json to list
#'
#' @param response "HttpResponse" as returned by client$get where
#' client was produced by `proj_idf_client()`
#'
#' @returns a list
#' @keywords internal
response_to_list <- function(response = NULL) {
  if ("HttpResponse" %in% class(response)) {
    response <- response$parse("UTF-8")
    list <- jsonlite::fromJSON(response, FALSE)
    return(list)
  } else {
    stop("Expecting an object of class 'HttpResponse'.")
  }
}

#' Replace type with category in resource list names
#'
#' @param idaifield_docs
#'
#' @returns the docs with "type" renamed to "category"
#'
#' @keywords internal
type_to_category <- function(docs) {
  docs <- lapply(docs, function(x) {
    type_ind <- which(names(x$doc$resource) == "type")
    if (length(type_ind) > 0) {
      names(x$doc$resource)[type_ind] <- "category"
    }
    return(x)
  })
  return(docs)
}


#' Name the list of `idaifield_docs` by identifier
#'
#' @param docs idaifield_docs
#'
#' @returns same, but named
#' @keywords internal
name_docs_list <- function(docs) {
  new_names <- lapply(docs, function(x)
    x$doc$resource$identifier)
  new_names <- unlist(new_names)
  names(docs) <- new_names
  return(docs)
}


#' TEMPORARY FUNCTION to warn about project(name)
#'
#' @param project connection$project
#' @param fail should there be an error?
#'
#' @return TRUE/FALSE
#'
#' @keywords internal
warn_for_project <- function(project = NULL, fail = FALSE) {
  if (!is.null(project)) {
    message <- paste("Please note: In the future, the project always",
                     "has to be supplied to `connect_idaifield()`.",
                     "Handing the project(name) as an argument to other",
                     "functions will be deprecated in one of the next",
                     "versions." )
    warning(message)
    if (fail) {
      stop("Please supply a project to `connect_idaifield()`.")
    } else {
      return(TRUE)
    }
  }
}




#' Reduces a (relations) list to its first element and warns accordingly.
#'
#' @param resource The resource to be checked
#' @param uuid The id/UUID of the resource (for warning)
#' @param identifier The identifier of the resource (for warning)
#'
#' @return The reduced relations list
#'
#' @keywords internal
reduce_relations <- function(relation, uuid = NA, identifier = NA) {
  if (!is.null(relation[[1]]) && length(relation[[1]]) > 1) {
    warning(paste0("Resource ", identifier, " (", uuid, ") has ",
                   length(relation[[1]]), " '", names(relation), "'-relations but only one is ",
                   "allowed. Using first entry (", relation[[1]][1], ")."))
    relation[[1]][2:length(relation[[1]])] <- NULL
  }
  return(relation)
}



#' Recursively Assign Names to All Nested Lists Based on "name" Field
#'
#' This function recursively traverses a nested list structure and assigns names
#' to unnamed sub-lists based on their `name` field or the `name` field contained
#' within an `item` sublist. It only assigns names if the list doesn't already have names.
#'
#' The function looks for the following naming rules:
#' 1. If a sublist contains an `item` sublist and that `item` sublist has a `name` field,
#'    the parent sublist is named based on the `item$name` value.
#' 2. If a sublist contains a `name` field directly, the parent sublist is named based on
#'    the `name` value.
#' 3. If neither `item$name` nor `name` exists, the sublist remains unnamed.
#'
#' The function continues to apply these rules recursively to all sublists, ensuring that
#' all unnamed sublists are appropriately named based on the above criteria.
#'
#' @param lst A nested list structure, where sublists may contain an `item` sublist or
#'            a `name` field.
#'
#' @return The same nested list structure, but with unnamed sublists assigned names
#'         based on the `name` or `item$name` field values.
#'
#' @examples
#' \dontrun{
#' test <- list(
#'   list(item = list(name = "1", value = "value1"), groups = list(
#'     list(name = "1a", fields = list(list(name = "1a-1"), list(name = "1a-2"))),
#'     list(name = "1b", fields = list(list(name = "1b-1"), list(name = "1b-2")))
#'   )),
#'   list(item = list(name = "2", value = "value1")),
#'   list(item = list(name = "3", value = "value1"), groups = list(
#'     list(name = "3a", fields = list(list(name = "3a-1"), list(name = "3a-2"))),
#'     list(name = "3b", fields = list(list(name = "3b-1"), list(name = "3b-2")))
#'   ))
#' )
#' named_list <- name_all_nested_lists(test)
#' print(named_list)
#' }
#'
#' @keywords internal
#'
name_all_nested_lists <- function(lst) {
  if (is.list(lst)) {
    if (is.null(names(lst))) {
      new_names <- lapply(lst, function(x) {
        if ("item" %in% names(x)) {
          name <- x$item$name
        } else if ("name" %in% names(x)) {
          name <- x$name
        } else {
          name <- NULL
        }
        return(name)
      })
      names(lst) <- new_names
    }
    lst <- lapply(lst, name_all_nested_lists)
  }
  return(lst)
}


#' Return a sub-list from a nested list by name
#'
#'
#' @param target_name a character value expected to be the name of one list
#' @param nested_list a nested list
#'
#' @return The first sub-list that has the name passed to target_name.
#' @export
#'
#' @examples
#' list <- list(first1 = list(second1 = list(1, 2, 3), second2 = list(4, 5, 6)), first2 = list(7, 8, 9))
#' find_named_list("second2", list)
find_named_list <- function(target_name, nested_list) {
  # Check if the current list contains the target name
  if (!is.null(names(nested_list)) && target_name %in% names(nested_list)) {
    result <- nested_list[[target_name]]
    return(result)  # Return the matching sublist
  }

  # Search recursively in all named sublists
  for (key in names(nested_list)) {
    if (is.list(nested_list[[key]])) {  # Ensure it's a list before recursion
      result <- find_named_list(target_name, nested_list[[key]])
      if (!is.null(result)) return(result)  # Return if a match is found
    }
  }

  return(NULL)  # Return NULL if no match found
}
