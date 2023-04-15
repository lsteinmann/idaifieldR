#' @title Show the *categories* Present in an `idaifield_docs`- or
#' `idaifield_resources`-list
#'
#' @description Returns a list of all *categories* present in the
#' iDAI.field 2 / Field Desktop database the list was imported from.
#'
#' @param idaifield_docs An an `idaifield_docs`- or `idaifield_resources`-list
#' as returned by [get_idaifield_docs()] or [idf_query()], [idf_index_query()]
#' and [idf_json_query()].
#'
#'
#'
#'
#'
#' @returns A character vector with the unique categories present in
#' the iDAI.field 2 / Field Desktop database the list was imported from.
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#'                                 user = "R",
#'                                 pwd = "hallo",
#'                                 project = "rtest")
#'
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' idf_show_categories(idaifield_docs)
#' }
#'
#' @export
idf_show_categories <- function(idaifield_docs) {
  resources <- check_and_unnest(idaifield_docs)
  cats <- lapply(resources, function(x) x$category)
  cats <- unlist(cats, use.names = FALSE)
  cats <- unique(cats)
  return(cats)
}


#' @title Deprecated function: Select/filter an `idaifield_resources`- or
#' `idaifield_docs`-list
#'
#' @description This function has been deprecated in favour
#' of [idf_select_by()].
#'
#' @details Subset or filter the list of the docs or resources by the
#' given parameters. You may want to consider querying the database
#' directly using [idf_query()], [idf_index_query()] and [idf_json_query()].
#'
#' @param idaifield_docs An `idaifield_resources`- or `idaifield_docs`-list
#' as returned by `get_idaifield_docs()` etc.
#' @param by Any name of a field that might by present in the resource lists,
#' e.g. category, identifier, processor etc.
#' @param value character. Should be the internal name of the value
#' that will be selected for (e.g. "Layer", "Pottery"), can also be vector of
#' multiple values.
#'
#' @returns A list of class `idaifield_resources` containing the resources
#' which contain the specified values.
#'
#' @export
#'
#' @keywords deprecated
#'
#' @seealso [idf_select_by()]
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo", project = "rtest")
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' idaifield_layers <- idf_select_by(idaifield_docs,
#' by = "category",
#' value = "Layer")
#'
#' idaifield_anna <- idf_select_by(idaifield_docs,
#' by = "processor",
#' value = "Anna Allgemeinperson")
#' }
select_by <- function(idaifield_docs,
                      by = c("category", "isRecordedIn"),
                      value = NULL) {

  .Deprecated("idf_select_by()", package = "idaifieldR", old = "select_by")
  result <- idf_select_by(idaifield_docs,
                          by = by,
                          value = value)
  return(result)
}

#' @title Select/Filter an `idaifield_resources`- or `idaifield_docs`-list
#'
#' @description Subset or filter the list of the *docs* or *resources* by the
#' given parameters. You may want to consider querying the database
#' directly using [idf_query()], [idf_index_query()], or [idf_json_query()].
#'
#' @param idaifield_docs An `idaifield_resources`- or `idaifield_docs`-list
#' as returned by [get_idaifield_docs()]  or [idf_query()], [idf_index_query()],
#' and [idf_json_query()].
#' @param by Any name of a field that might by present in the resource lists,
#' e.g. category, identifier, processor etc.
#' @param value character. Should be the internal name of the value
#' that will be selected for (e.g. "Layer", "Pottery"), can also be vector of
#' multiple values.
#'
#' @returns A list of class `idaifield_resources` containing the resources
#' which contain the specified values.
#'
#'
#'
#'
#'
#' @export
#'
#' @seealso [get_idaifield_docs()], [idf_show_categories()]
#' [idf_query()], [idf_index_query()], [idf_json_query()]
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo", project = "rtest")
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' idaifield_layers <- idf_select_by(idaifield_docs,
#' by = "category",
#' value = "Layer")
#'
#' idaifield_anna <- idf_select_by(idaifield_docs,
#' by = "processor",
#' value = "Anna Allgemeinperson")
#' }
idf_select_by <- function(idaifield_docs,
                          by = NULL,
                          value = NULL) {
  if (is.null(by)) {
    stop("Argument `by` cannot be empty.")
  } else if (length(by) > 1) {
    warning("Please supply only one character string to `by` (using first).")
    by <- by[1]
  }
  if (is.null(value)) {
    stop("Argument `value` cannot be empty.")
  }

  resources <- check_and_unnest(idaifield_docs)

  result <- Filter(function(x) {
    unlist(x[[by]]) %in% value
    }, resources)

  attributes <- attributes(idaifield_docs)
  attributes <- attributes[-which(names(attributes) == "names")]
  attributes(result) <- append(attributes(result), attributes)
  result <- structure(result, class = "idaifield_resources")

  return(result)
}
