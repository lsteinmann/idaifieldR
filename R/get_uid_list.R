#' @title Get the Index of an `idaifield_docs`/`idaifield_resources`-list
#'
#' @description All resources in the project databases in
#' [iDAI.field / Field Desktop](https://github.com/dainst/idai-field) are
#' stored and referenced with their Universally Unique Identifier (UUID)
#' in the relations fields. Therefore, for many purposes a lookup-table needs
#' to be provided in order to get to the actual identifiers of the resources
#' referenced. Single UUIDs or vectors of UUIDs can be replaced individually
#' using [replace_uid()] from this package.
#'
#' This function is also good for a quick overview / a list of all the
#' resources that exist along with their identifiers and short descriptions
#' and can be used to select the resources along their respective
#' Categories (e.g. Pottery, Layer etc., formerly named "type").
#' Please note that in any case the internal names of everything will be used.
#' If you relabeled `Trench` to `Schnitt` in your language-configuration,
#' the name will still be `Trench` here. None of these functions have any
#' respect for language settings of a project configuration, i.e. the
#' front end languages of valuelists and fields are not displayed, and
#' instead their background names are used. You can see these in the project
#' configuration settings.
#'
#' @param idaifield_docs An object as returned by [get_idaifield_docs()]
#' @inheritParams get_field_index
#'
#' @returns a data.frame with identifiers and corresponding UUIDs along with
#' the category (former: type), basic relations and depending on settings
#' place, shortDescription and "liesWithinLayer" of each element
#'
#' @seealso
#' * Superseded by [get_field_index()], which queries the database directly.
#' * [find_layer()] is used when `find_layers = TRUE` to search for the
#' containing layer-resource recursively.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#'                                 user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = connection,
#'                                      projectname = "rtest")
#'
#' uidlist <- get_uid_list(idaifield_docs, verbose = TRUE)
#' }
get_uid_list <- function(idaifield_docs,
                         verbose = FALSE,
                         gather_trenches = FALSE,
                         remove_config_names = TRUE,
                         find_layers = FALSE,
                         language = "all") {
  #.Deprecated("get_field_index()", package = "idaifieldR", #msg,
  #            old = "get_uid_list()")

  stopifnot(is.logical(verbose))
  stopifnot(is.logical(gather_trenches))
  stopifnot(is.logical(remove_config_names))
  stopifnot(is.logical(find_layers))

  idaifield_docs <- check_and_unnest(idaifield_docs)

  ncol <- 5
  colnames <- c("category", "UID", "identifier", "isRecordedIn", "liesWithin")

  if (verbose) {
    ncol <- 7
    colnames <- c(colnames, "shortDescription", "liesWithinLayer")
  }

  uidlist <- data.frame(matrix(nrow = length(idaifield_docs), ncol = ncol))
  colnames(uidlist) <- colnames

  uidlist$UID <- unlist(lapply(idaifield_docs,
                               FUN = function(x) na_if_empty(x$id)))

  category <- unlist(lapply(idaifield_docs,
                            FUN = function(x) na_if_empty(x$category)))
  if (any(is.na(category))) {
    type <- unlist(lapply(idaifield_docs,
                          FUN = function(x) na_if_empty(x$type)))
    uidlist$category <- ifelse(is.na(category), type, category)
  } else {
    uidlist$category <- category
  }

  if (remove_config_names) {
    uidlist$category <- remove_config_names(uidlist$category, silent = TRUE)
  }

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

  # It should not be possible to have more than one liesWithin-relation, but it apparently can occur.
  uidlist$liesWithin <- unlist(
    lapply(idaifield_docs,
           function(x) {
             x$relations["liesWithin"] <- reduce_relations(x$relations["liesWithin"],
                                                           x$id,
                                                           x$identifier)
             na_if_empty(x$relations$liesWithin)
           }))
  if (all(is.na(uidlist$liesWithin))) {
    uidlist$liesWithin <- unlist(lapply(idaifield_docs,
                                        function(x) na_if_empty(x$relation.liesWithin)[1]))
  }

  if (verbose) {
    # get all entries for shortDescription
    desc <- lapply(idaifield_docs, function(x) na_if_empty(x$shortDescription))
    if (language == "all") {
      desc <- lapply(idaifield_docs,
                     function(x) na_if_empty(x$shortDescription))
      desc <- lapply(desc, function(x) paste0(names(x), ": ",
                                              x, collapse = "; "))
      uidlist$shortDescription <- gsub(": NA", NA, desc)
    } else {
      uidlist$shortDescription <- gather_languages(desc, language = language)
    }
  }

  if (find_layers) {
    lwl <- find_layer(uidlist$UID, uidlist)
    uidlist$liesWithinLayer <- replace_uid(lwl, uidlist)
  }

  uidlist$isRecordedIn <- replace_uid(uidlist$isRecordedIn, uidlist)
  uidlist$liesWithin <- replace_uid(uidlist$liesWithin, uidlist)

  if (gather_trenches) {
    uidlist$Place <- gather_trenches(uidlist)
  }

  return(uidlist)
}



#' @title Get the Index of an iDAI.field / Field Desktop Database
#'
#' @description All resources in the project databases in iDAI.field /
#' Field Desktop are stored and referenced with their Universally Unique
#' Identifier (UUID) in the relations fields. Therefore, for many purposes a
#' lookup-table needs to be provided in order to get to the actual identifiers
#' of the resources referenced. Single UUIDs or vectors of UUIDs can be
#' replaced individually using [replace_uid()] from this package.
#'
#' This function is also good for a quick overview / a list of all the
#' resources that exist along with their identifiers and short descriptions
#' and can be used to select the resources along their respective
#' Categories (e.g. Pottery, Layer etc., formerly names "types").
#' Please note that in any case the internal names of everything will be used.
#' If you relabeled `Trench` to `Schnitt` in your language-configuration,
#' the name will still be `Trench` here. None of these functions have any
#' respect for language settings of a project configuration, i.e. the
#' front end languages of valuelists and fields are not displayed, and
#' instead their background names are used. You can see these in the project
#' configuration settings.
#'
#' @param connection An object as returned by [connect_idaifield()]
#' @param verbose TRUE or FALSE. Defaults to FALSE. TRUE returns a list
#' including identifier and shortDescription which is more convenient to read,
#' and FALSE returns only UUID, category (former: type) and basic relations,
#' which is sufficient for internal use.
#' @param gather_trenches defaults to FALSE. If TRUE, adds another column that
#' records the Place each corresponding Trench and its sub-resources lie within.
#' (Useful for grouping the finds of several trenches, but will only work if the
#' project database is organized accordingly.)
#' @param find_layers TRUE/FALSE. Default is FALSE. If TRUE, adds another column
#' with the 'Layer' (see `getOption("idaifield_categories")$layers`, can be
#' modified) in which a resource is contained  recursively. That means that
#' even if it does not immediately lie within this layer, but is
#' contained by one or several other resources in said layer, a new column
#' ("liesWithinLayer") will still show the layer.
#' Example: A sample "A" in Find "001" from layer "Layer1" will
#' usually have "001" as the value in "liesWithin". With find_layers, there will
#' be another column called "liesWithinLayer" which contains "Layer1" for both
#' sample "A" and Find "001".
#' @inheritParams gather_languages
#' @inheritParams get_field_inputtypes
#'
#' @returns a data.frame with identifiers and corresponding UUIDs along with
#' the category (former: type), basic relations and depending on settings place
#' and shortDescription of each element
#' @export
#'
#' @seealso
#' * [get_uid_list()] returns the same data.frame from an `idaifield_docs` or
#' `idaifield_resources`-list without querying the database.
#' * [find_layer()] is used when `find_layers = TRUE` to search for the
#' containing layer-resource recursively.
#'
#'
#'
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(pwd = "hallo", project = "rtest")
#'
#' index <- get_field_index(connection, verbose = TRUE)
#' }
get_field_index <- function(connection,
                            verbose = FALSE,
                            gather_trenches = FALSE,
                            remove_config_names = TRUE,
                            find_layers = FALSE,
                            language = "all") {

  stopifnot(is.logical(verbose))
  stopifnot(is.logical(gather_trenches))
  stopifnot(is.logical(remove_config_names))
  stopifnot(is.logical(find_layers))


  fields <- c("type", "category",
              "id", "identifier",
              "relations.isRecordedIn",
              "relations.liesWithin")
  if (verbose) {
    fields <- c(fields, "shortDescription")
  }
  q_fields <- paste0("resource.", fields)

  query <- paste0(
    '{ "selector": { "$not": { "resource.id": "" } },
   "fields": [', paste0('"', q_fields, '"', collapse = ", "), '] }')
  if(!jsonlite::validate(query)) {
    stop("Something went wrong. Could not validate query.")
  }

  # db query here
  client <- proj_idf_client(connection, include = "query")
  response <- response_to_list(client$post(body = query))
  response <- unnest_docs(response)

  fields <- gsub("relations.", "", fields)
  fields <- fields[!fields == "type"]


  index_df <- lapply(response, function(x) {
    # switch remaining 'type' list names to 'category'
    type_ind <- names(x) == "type"
    if (any(type_ind)) {
      names(x)[type_ind] <- "category"
    }


    # check if liesWithin contains only one element, if not: discard and warn
    x$relations["liesWithin"] <- reduce_relations(x$relations["liesWithin"],
                                                  x$id,
                                                  x$identifier)

    # unlist and append the relations list to top level list
    rel <- unlist(x$relations)
    x <- append(x, rel)
    x$relations <- NULL
    # add empty lists if necessary to that rbind will work
    if (length(fields) != length(names(x))) {
      to_add <- which(!fields %in% names(x))
      x[fields[to_add]] <- NA
    }
    # reorder the list
    x <- x[fields]
  })
  index_df <- do.call(rbind.data.frame, index_df)

  # get rid of confignames
  index_df$category <- remove_config_names(index_df$category, silent = TRUE)

  # get rid of UUIDs
  index_df$isRecordedIn <- replace_uid(index_df$isRecordedIn, index_df)
  index_df$liesWithin <- replace_uid(index_df$liesWithin, index_df)

  if (verbose) {
    # not sure if this really works, but seems okay?
    index_df$shortDescription <- gather_languages(index_df$shortDescription,
                                                  language = language)
  }
  if (find_layers) {
    index_df$liesWithinLayer <- find_layer(index_df$identifier, index_df)
  }

  if (gather_trenches) {
    index_df$Place <- gather_trenches(index_df)
  }

  uuidcol <- which(colnames(index_df) == "id")
  colnames(index_df)[uuidcol] <- "UID"

  # remove the Configuration as it metadata
  config_ind <- which(index_df$identifier == "Configuration")
  if (length(config_ind) != 0) {
    index_df <- index_df[-config_ind, ]
  }

  return(index_df)
}

#' Get a vector of *Place*-resources each element from the index is located in
#'
#' @param uidlist as returned by [get_uid_list()]
#' and [get_field_index()]
#'
#' @returns a vector containing the Place each resource is located in
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' uidlist$Place <- gather_trenches(uidlist)
#' }
gather_trenches <- function(uidlist) {
  gather_mat <- matrix(ncol = 3, nrow = nrow(uidlist))
  gather_mat[, 1] <- ifelse(is.na(uidlist$isRecordedIn),
                            uidlist$liesWithin,
                            uidlist$isRecordedIn)
  gather_mat[, 2] <- uidlist$category[match(gather_mat[, 1],
                                            uidlist$identifier)]
  gather_mat[, 3] <- uidlist$liesWithin[match(gather_mat[, 1],
                                              uidlist$identifier)]
  places <- ifelse(gather_mat[, 2] == "Trench",
                   gather_mat[, 3],
                   gather_mat[, 1])
  return(places)
}
