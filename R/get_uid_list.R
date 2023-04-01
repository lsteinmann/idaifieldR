#' get_uid_list: Get the index of an idaifield_docs/resources object.
#'
#' All resources in the project databases in iDAI.field / Field Desktop are
#' stored and referenced with their Universally Unique Identifier (UUID)
#' in the relations fields. Therefore, for many purposes a lookup-table needs
#' to be provided in order to get to the actual identifiers of the resources
#' referenced. Single UUIDs or vectors of UUIDs can be replaced individually
#' using `replace_uid()` from this package.
#'
#' This function is also good for a quick overview / a list of all the
#' resources that exist along with their identifiers and short descriptions
#' and can be used to select the resources along their respective
#' Types/Categories (e.g. Pottery, Layer etc.). Please note that in any case
#' the internal names of everything will be used. If you relabeled `Trench`
#' to `Schnitt` in your language-configuration, the name will still be
#' `Trench` here. None of these functions have any respect for language
#' settings of a project configuration, i.e. the front end languages of
#' valuelists and fields are not displayed, and instead their background
#' names are used. You can see these in the project configuration settings.
#'
#' @param idaifield_docs An object as returned by `get_idaifield_docs()`
#' @param verbose TRUE or FALSE. Defaults to FALSE. TRUE returns a list
#' including identifier and shortDescription which is more convenient to read,
#' and FALSE returns only UUID, type (category) and basic relations,
#' which is sufficient for internal use.
#' @param gather_trenches defaults to FALSE. If TRUE, adds another column that
#' records the Place each corresponding Trench and its sub-resources lie within.
#' (Useful for grouping the finds of several trenches, but will only work if
#' the project database is organized accordingly.)
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the multi-language input "shortDescription",
#' defaults to all (`language = "all"`). Will select other available languages
#' in alphabetical order if the selected language is not available.
#'
#' @return a data.frame with identifiers and corresponding UUIDs along with
#' the type (category), basic relations and depending on settings place and
#' shortDescription of each element
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
                         language = "all") {
  #warning("The function `get_uid_list()` is deprecated and will be removed
  #        in an upcoming version of idaifieldR. Please switch to
  #        `get_field_index()`.")
  .Deprecated("get_field_index()", package = "idaifieldR", #msg,
              old = "get_uid_list()")

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

  type <- unlist(lapply(idaifield_docs,
                        FUN = function(x) na_if_empty(x$type)))
  if (any(is.na(type))) {
    category <- unlist(lapply(idaifield_docs,
                              FUN = function(x) na_if_empty(x$category)))
    uidlist$type <- ifelse(is.na(type), category, type)
  } else {
    uidlist$type <- type
  }

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
    if (language == "all") {
      desc <- lapply(idaifield_docs,
                     function(x) na_if_empty(x$shortDescription))
      desc <- lapply(desc, function(x) paste0(names(x), ": ",
                                              x, collapse = "; "))
      uidlist$shortDescription <- gsub(": NA", NA, desc)
    } else {
      uidlist$shortDescription <- gather_languages(desc, language = language)
    }
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



#' Get the index of an iDAI.field/Field Desktop database
#'
#' All resources in the project databases in iDAI.field / Field Desktop are
#' stored and referenced with their Universally Unique Identifier (UUID)
#' in the relations fields. Therefore, for many purposes a lookup-table needs
#' to be provided in order to get to the actual identifiers of the resources
#' referenced. Single UUIDs or vectors of UUIDs can be replaced individually
#' using `replace_uid()` from this package.
#'
#' This function is also good for a quick overview / a list of all the
#' resources that exist along with their identifiers and short descriptions
#' and can be used to select the resources along their respective
#' Types/Categories (e.g. Pottery, Layer etc.). Please note that in any case
#' the internal names of everything will be used. If you relabelled `Trench`
#' to `Schnitt` in your language-configuration, the name will still be
#' `Trench` here. None of these functions have any respect for language
#' settings of a project configuration, i.e. the front end languages of
#' valuelists and fields are not displayed, and instead their background
#' names are used. You can see these in the project configuration settings.
#'
#' @param connection An object as returned by `connect_idaifield()`
#' @param verbose TRUE or FALSE. Defaults to FALSE. TRUE returns a list
#' including identifier and shortDescription which is more convenient to read,
#' and FALSE returns only UUID, type (category) and basic relations,
#' which is sufficient for internal use.
#' @param gather_trenches defaults to FALSE. If TRUE, adds another column that
#' records the Place each corresponding Trench and its sub-resources lie within.
#' (Useful for grouping the finds of several trenches, but will only work if the
#' project database is organized accordingly.)
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the multi-language input "shortDescription",
#' defaults to english ("en") and will select other available languages in
#' alphabetical order if the selected language is not available.
#'
#' @return a data.frame with identifiers and corresponding UUIDs along with
#' the type (category), basic relations and depending on settings place and
#' shortDescription of each element
#' @export
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(serverip = "127.0.0.1",
#'                                 user = "R", pwd = "hallo")
#'
#' index <- get_index(connection, verbose = TRUE)
#' }
get_field_index <- function(connection, verbose = FALSE,
                      gather_trenches = FALSE,
                      language = "en") {

  query <- paste0(
    '{ "selector": { "$not": { "resource.id": "" } },
   "fields": [ "resource.id", "resource.identifier" ]}')
  client <- proj_idf_client(connection, include = "query")

  response <- response_to_list(client$post(body = query))
  uuids <- unnest_docs(response)
  uuids <- do.call(rbind.data.frame, uuids)

  fields <- c("identifier", "id",
              "type", "category",
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

  response <- response_to_list(client$post(body = query))
  response <- unnest_docs(response)

  fields <- gsub("relations.", "", fields)
  fields <- fields[!fields == "type"]

  index <- lapply(response, function(x) {
    type_ind <- names(x) == "type"
    if (any(type_ind)) {
      names(x)[type_ind] <- "category"
    }
    rel <- unlist(x$relations)
    x$relations <- NULL
    x <- append(x, rel)
    if (length(fields) != length(names(x))) {
      to_add <- which(!fields %in% names(x))
      x[fields[to_add]] <- NA
    }
    x <- x[fields]
    x$shortDescription <- gather_languages(x$shortDescription,
                                           language = language)
    if (check_if_uid(x$isRecordedIn)) {
      x$isRecordedIn <- replace_uid(x$isRecordedIn, uuids)
    }
    if (check_if_uid(x$liesWithin)) {
      x$liesWithin <- replace_uid(x$liesWithin, uuids)
    }

    return(x)
  })
  index_df <- do.call(rbind.data.frame, index)

  if (verbose) {
    index <- lapply(index, function(x) {
      x$liesWithinLayer <- find_layer(x, index_df)
      return(x)
    })
    lwl <- lapply(index, function(x) x$liesWithinLayer)
    lwl <- unlist(na_if_empty(lwl))
    index_df$liesWithinLayer <- lwl
  }

  if (gather_trenches) {
    gather_mat <- matrix(ncol = 3, nrow = nrow(index_df))
    gather_mat[, 1] <- ifelse(is.na(index_df$isRecordedIn),
                              index_df$liesWithin,
                              index_df$isRecordedIn)
    gather_mat[, 2] <- index_df$category[match(gather_mat[, 1],
                                               index_df$identifier)]
    gather_mat[, 3] <- index_df$liesWithin[match(gather_mat[, 1],
                                                 index_df$identifier)]
    index_df$Place <- ifelse(gather_mat[, 2] == "Trench",
                             gather_mat[, 3],
                             gather_mat[, 1])
  }

  return(index_df)
}
