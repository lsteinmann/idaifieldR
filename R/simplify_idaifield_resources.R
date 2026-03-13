#' Simplifies a single resource from the iDAI.field 2 / Field Desktop Database
#'
#' This function is a helper to `simplify_idaifield()`.
#'
#' @param resource One resource (element) from an `idaifield_resources`-list.
#' @inheritParams simplify_idaifield
#' @inheritParams get_field_index
#' @param keep_geometry Should the geometry of each resource be kept?
#' @param replace_uids TRUE/FALSE: Should UUIDs be automatically replaced with the
#' corresponding identifiers? Defaults is TRUE. Uses: [fix_relations()] with
#' [replace_uid()], and also: [find_layer()]
#'
#'
#' @returns A single resource (element) for an `idaifield_resources`-list.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' simpler_resource <- simplify_single_resource(resource,
#' replace_uids = TRUE,
#' uidlist = uidlist,
#' keep_geometry = FALSE)
#' }
simplify_single_resource <- function(resource,
                                     index = NULL,
                                     config = NULL,
                                     replace_uids = TRUE,
                                     find_layers = TRUE,
                                     keep_geometry = TRUE,
                                     language = "all",
                                     silent = FALSE) {

  stopifnot(is.logical(keep_geometry))
  stopifnot(is.logical(replace_uids))
  stopifnot(is.logical(find_layers))
  stopifnot(is.logical(silent))

  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from a 'idaifield_resources'-list.")
  }
  # We need the config for handling inputTypes.
  if (find_layers && !inherits(config, "idaifield_config")) {
    # Change if you decide we not NEED the config after all.
    stop("'config' is not an 'idaifield_config'")
  }

  # ----- Legacy data fixes
  # In a previous version of iDAI.field, "type" was used to store the (then)
  # "type" of resource. This was renamed to "category" after the TypeCatalog
  # feature was implemented. Since not every resource in the DB has been
  # updated to fit the new scheme, we need to do this retroactively:
  if (is.null(resource$category)) {
    resource$category <- resource$type
    resource$type <- NULL
  }
  # TODO Question: Should this maybe be a function that can be used elsewhere?
  # It is a little like "migrating" the data model to the current state and will
  # be relevant. However - not doing that now.
  # TODO: handling of legacy "date" fields which are now more complex.




  # ----- Spread relations into specific vectors for each relation
  # such as e.g. relation.liesWithin = c("Befund 1")
  resource <- fix_relations(resource, replace_uids = replace_uids, index = index)

  # ----- Find the next containing resource considered a "layer"
  # A layer here would be Feature or a sub-category of feature as evident
  # from the project configuration.
  if (find_layers) {
    resource$relation.liesWithinLayer <- unname(find_layer(
      resource$identifier,
      index,
      layer_categories = c("Feature", names(config$categories$Feature$trees))
    ))
  }

  # ----- Handle the geometry appropriately
  if (keep_geometry && !is.null(resource$geometry)) {
    resource$geometry <- maybe_to_json(resource$geometry)
  } else {
    resource$geometry <- NULL
  }



#
  #if (language != "all") {
  #  resource <- lapply(resource, function(x) {
  #    pat <- c("^[a-z]{2}$", "unspecifiedLanguage")
  #    names <- names(x)
  #    names <- grepl(paste0(pat, collapse = "|"), names)
  #    if (all(names)) {
  #      gather_languages(list(x), language = language, silent = TRUE)
  #    } else {
  #      x
  #    }
  #  })
  #}

  # ----- Unlist fields that do not have sub-lists to vectors:
  resource <- lapply(resource, function(x) {
    if (!check_for_sublist(x)) {
      unlist(x)
    } else {
      x
    }
  })

  return(resource)
}

#' Simplify a List Imported from an iDAI.field / Field Desktop-`1041-1`#' Simplify a List Imported from an iDAI.field / Field Desktop-Database
#'
#' The function will take a list as returned by
#' [get_idaifield_docs()], [idf_query()], [idf_index_query()], or
#' [idf_json_query()] and process it to make the list more usable.
#' It will unnest a few lists, including the dimension-lists and the
#' period-list to provide single values for later processing with
#' [idaifield_as_matrix()].
#' If a connection to the database can be established, the function will
#' get the relevant project configuration and convert custom checkboxes-fields
#' to multiple lists, each for every value from the respective valuelist,
#' to make them more accessible during the conversion with
#' [idaifield_as_matrix()].
#' It will also remove the custom configuration field names that are in use
#' since iDAI.field 3 / Field Desktop and consist of "projectname:fieldName".
#' Only the "projectname:"-part will be removed.
#'
#' Please note: The function will need an Index (i.e. uidlist as provided
#' by [get_uid_list()]) of the complete project database to correctly replace
#' the UUIDs with their corresponding identifiers! Especially if a selected
#' list is passed to [simplify_idaifield()], you need to supply the uidlist
#' of the complete project database as well.
#'
#' Formatting of various lists: Dimension measurements as well as dating are
#' reformatted and might produce unexpected results.
#' For the dating, all begin and end values are evaluated and for each resource,
#' the minimum value from "begin" and maximum value from "end" is selected.
#' For the dimension-fields, if a ranged measurement was selected, a mean
#' will be returned.
#'
#' @param idaifield_docs An `idaifield_docs` or `idaifield_resources`-list as
#' returned by [get_idaifield_docs()] or [idf_query()],
#' [idf_index_query()], and [idf_json_query()].
#' @inheritParams get_field_index
#' @param index If NULL (default) the list of UUIDs and identifiers is
#' automatically generated within this function using [get_uid_list()]. This only makes sense if
#' the list handed to [simplify_idaifield()] had not been selected yet. If it
#' has been, you should supply a data.frame as returned
#' by [get_field_index()].
#' @param silent TRUE/FALSE, default: FALSE. Should messages be suppressed?
#' @inheritParams gather_languages
#' @inheritParams get_field_inputtypes
#'
#' @returns An `idaifield_simple`-list containing the same resources in
#' a different format depending on the parameters used.
#'
#' @export
#'
#'
#' @seealso
#' * This function uses: [idf_sepdim()], [remove_config_names()]
#' * When find_layers = TRUE: [find_layer()], this only works when the function can get an index/uidlist!
#' * Depending on the `replace_uids`-argument: [fix_relations()] with [replace_uid()]
#' * If `uidlist = NULL`: [get_uid_list()]
#'
#'
#' @examples
#' \dontrun{
#' connection <- connect_idaifield(
#'     serverip = "localhost",
#'     project = "rtest",
#'     pwd = "hallo"
#' )
#' idaifield_docs <- get_idaifield_docs(connection = connection)
#'
#' simpler_idaifield <- simplify_idaifield(idaifield_docs)
#' }
simplify_idaifield <- function(resources,
                               index = NULL,
                               config = NULL,
                               silent = FALSE,
                               language = "all",
                               keep_geometry = FALSE,
                               # DEPRECATED --------
                               uidlist = NULL,
                               remove_config_names = NULL,
                               spread_fields = NULL,
                               use_exact_dates = NULL
                               ) {


  # Warn for deprecated parameters:
  if (!is.null(remove_config_names)) {
    warning("'remove_config_names' argument is deprecated. do not use it anymore.")
  }
  if (!is.null(use_exact_dates)) {
    warning("'use_exact_dates' argument is deprecated. do not use it anymore.")
  }
  if (!is.null(spread_fields)) {
    warning("'spread_fields' argument is deprecated. do not use it anymore.")
  }
  if (!is.null(uidlist)) {
    warning("'uidlist' argument has been renamed to 'index'. do not use it anymore.")
    if (is.null(index)) {
      index <- uidlist
    }
  }


  #### ---------- Check if the declared structure is as expected
  if (inherits(resources, "idaifield_simple")) {
    message("'resources' is already an 'idaifield_simple', did nothing.")
    return(resources)
  }
  resources <- maybe_unnest_docs(resources)
  if (!inherits(resources, "idaifield_resources")) {
    stop("'resources' is not an 'idaifield_resources'.")
  }

  # We need the index for UUID replacement.
  if (is.null(index)) {
    # TODO
    # Consider removing this.
    message("No 'index' supplied, generating from this list.")
    index <- get_uid_list(resources)
  }
  # We need the config for handling inputTypes.
  if (is.null(config)) {
    conn <- attr(resources, "connection")
    config <- get_configuration(conn)
  } else if (!inherits(config, "idaifield_config")) {
    # Change if you decide we not NEED the config after all.
    stop("'config' is not an 'idaifield_config'")
  }

  # Workflow in this pipe-function:
  # A) check for structure - DONE
  # B) replace UUIDs, don't make that an argument. you want it simple, you get it simple.
  # It would be a lot faster though if I'd replace UUIDs after I did the whole relations thing.
  # C) think about languages: every list should be traversed to check if it has a language list,
  # and from that language list, a language needs to be selected. Selecting "all" can stay possible,
  # and in that case, the language list just isnt touched. Users problem.
  # D) spread the relations list, so that each relation has either its own list,
  # or just the value?
  # E) Select only things that can be easily tabulated: anything that is not a list.
  # F) I actually still like the idea of attaching a place (though we can have that in the index... not needed, actually.)
  # G) handle_geometry: put the JSON geometry in an R-readable format?


  # the find_layer() function is nicer and faster if we use the vectorized way.
  layer_categories <- c("Feature", names(config$categories$Feature$trees))
  liesWithinLayer <- find_layer(
    names(resources),
    index,
    layer_categories = layer_categories
  )



  # Workflow on a single resource:
  idaifield_simple <- lapply(resources, function(x) {
    new_res <- simplify_single_resource(
      x,
      index = index,
      config = config,
      language = language,
      silent = silent,
      find_layers = FALSE,
      replace_uids = TRUE,
      keep_geometry = keep_geometry
    )
    lwl <- which(names(liesWithinLayer) == x$identifier)
    lwl <- liesWithinLayer[lwl]
    if (length(lwl) > 0) {
      names(lwl) <- "relation.liesWithinLayer"
      new_res <- append(new_res, lwl)
    }
    return(new_res)
  })

  idaifield_simple <- structure(idaifield_simple, class = "idaifield_simple")
  attr(idaifield_simple, "connection") <- attr(resources, "connection")
  attr(idaifield_simple, "projectname") <- attr(resources, "projectname")
  attr(idaifield_simple, "language") <- language

  return(idaifield_simple)
}










