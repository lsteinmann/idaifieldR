#' Simplifies a single resource from the iDAI.field 2 / Field Desktop Database
#'
#' This function is a helper to `simplify_idaifield()`.
#'
#' @param resource One resource (element) from an `idaifield_resources`-list.
#' @inheritParams simplify_idaifield
#' @inheritParams get_field_index
#' @param keep_geometry TRUE/FALSE: Should the geographical
#' information be kept or removed? Defaults is FALSE. Uses: [reformat_geometry()]
#' @param replace_uids TRUE/FALSE: Should UUIDs be automatically replaced with the
#' corresponding identifiers? Defaults is TRUE. Uses: [fix_relations()] with
#' [replace_uid()], and also: [find_layer()]
#'
#' @param spread_fields TRUE/FALSE: Should checkbox-fields be
#' spread across multiple lists to facilitate boolean-columns for each value
#' of a checkbox-field? Default is TRUE. Uses: [get_configuration()],
#' [get_field_inputtypes()], [convert_to_onehot()]
#' @param use_exact_dates TRUE/FALSE: Should the values from any "exact"
#' dates be used in case there are any? Default is FALSE. Changes outcome of [fix_dating()].
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
                                     silent = FALSE,
                                     # DEPRECATED --------
                                     uidlist = NULL,
                                     remove_config_names = NULL,
                                     spread_fields = NULL,
                                     use_exact_dates = NULL) {

  stopifnot(is.logical(keep_geometry))
  stopifnot(is.logical(replace_uids))
  stopifnot(is.logical(find_layers))
  stopifnot(is.logical(silent))

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

  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from a 'idaifield_resources'-list.")
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






  #resource <- fix_relations(resource,
  #                          replace_uids = replace_uids,
  #                          uidlist = uidlist)
#
  ## checks the value of the replace_uids argument, if it is TRUE,
  ## calls the find_layer() function on the resource with resource, uidlist,
  ## and NULL as arguments. The resulting value is assigned to the
  ## liesWithinLayer variable and appended to the resource as a new field
  ## called relation.liesWithinLayer.
  #if (find_layers) {
  #  liesWithinLayer <- find_layer(ids = resource$id,
  #                                uidlist = uidlist,
  #                                silent = TRUE)
  #  if (replace_uids) {
  #    liesWithinLayer <- replace_uid(liesWithinLayer, uidlist)
  #  }
  #  resource <- append(resource,
  #                     list(relation.liesWithinLayer = liesWithinLayer))
  #}
#
  ## checks the value of the keep_geometry argument, which determines whether
  ## to keep the geometry field in the resource or not. If keep_geometry is
  ## FALSE, the function checks if the resource has a field called geometry and,
  ## if so, removes it. If keep_geometry is TRUE, the reformat_geometry()-
  ## function is called on the resource's geometry field and the resulting value
  ## is assigned back to the geometry field of the resource.
  #if (!keep_geometry) {
  #  names <- names(resource)
  #  has_geom <- any(grepl("geometry", names))
  #  if (has_geom) {
  #    resource$geometry <- NULL
  #  }
  #} else {
  #  resource$geometry <- reformat_geometry(resource$geometry)
  #}
#
  ## Next, the function checks if the resource has a field called period, and
  ## if so, assigns it to the period variable. If period is not NULL,
  ## the function creates a new fixed_periods variable with two elements,
  ## named period.start and period.end. If period has only one element,
  ## both elements of fixed_periods are set to this value. If period has two
  ## elements, the elements of fixed_periods are set to these values.
  ## If period has more than two elements, a message is printed saying
  ## "I did not see that coming." and the values of fixed_periods are not
  ## modified. The fixed_periods variable is then appended to the resource.
  #period <- resource$period
  #if (!is.null(period)) {
  #  fixed_periods <- c(NA, NA)
  #  names(fixed_periods) <- c("period.start", "period.end")
  #  if (length(period) == 1) {
  #    fixed_periods[1:2] <- rep(unlist(period), 2)
  #  } else if (length(period) == 2) {
  #    fixed_periods[1:2] <- unlist(period)
  #  } else {
  #    # this actually never ever happens ;)
  #    message(paste("Somehow, resource", id,
  #                  "has more than two values for field 'period'.",
  #                  "Using first two."))
  #    fixed_periods[1:2] <- unlist(period)[1:2]
  #  }
  #  resource <- append(resource, fixed_periods)
  #}
#
  #dating <- resource[["dating", exact = TRUE]]
  #if (!is.null(dating)) {
  #  dating <- fix_dating(dating, use_exact_dates = use_exact_dates)
  #  resource$dating <- NULL
  #  resource <- append(resource, dating)
  #}
#
#
  ## Next, the function gets all the field names in the resource that contain
  ## the string "dimension", and assigns them to the dim_names variable.
  ## If dim_names has at least one element, the function creates a new new_dims
  ## list with a single element (1), and then iterates over each element of
  ## dim_names. For each dim in dim_names, the idf_sepdim() function is called,
  ## passing dim (the name of the field in question) as an additional argument.
  ## The result is appended to the new_dims list. Once all elements of dim_names
  ## have been processed, the new_dims list is converted to a flat list
  ## (i.e., all sub-lists are removed) and the fields in resource with names
  ## from dim_names are removed. The new_dims list is then appended
  ## to the resource.
  #list_names <- names(resource)
  #dim_names <- list_names[grep("dimension", list_names)]
#
  #if (length(dim_names) >= 1) {
  #  new_dims <- as.list(1)
  #  for (dim in dim_names) {
  #    # We are doing this silently always, why would we do this to users,
  #    # we cant just calculate the mean and say its cool.
  #    new_dims <- append(new_dims, idf_sepdim(resource[[dim]], dim))
  #  }
  #  new_dims <- as.list(unlist(new_dims[-1]))
#
#
  #  resource[dim_names] <- NULL
#
  #  resource <- append(resource, new_dims)
  #}
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
#
#
#
  ## Finally, the function checks if the fieldtypes argument is a matrix,
  ## and if so, calls the convert_to_onehot() function on the resource with
  ## fieldtypes as an additional argument. This converts the values in the
  ## fields of resource to one-hot encoded vectors based on the
  ## specified fieldtypes.
  ## Have to retire this completely.
  #if (spread_fields & !any(is.na(config))) {
  #  #warning("fields can currently not be converted to one hot; waiting on rework of simplify_idaifield")
  #  #resource <- convert_to_onehot(resource = resource,
  #  #                              config = config)
  #  # TODO
  #}
#
  ## Then, returns the modified resource.
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
#' * [fix_dating()] with the outcome depending on the `use_exact_dates`-argument.
#' * When selecting a language: [gather_languages()]
#' * Depending on the `spread_fields`-argument: [convert_to_onehot()]
#' * Depending on the `keep_geometry`-argument: [reformat_geometry()]
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
                               language = "all"
                               #keep_geometry = FALSE,
                               #uidlist = NULL,
                               #language = "all",
                               #remove_config_names = TRUE,
                               #spread_fields = TRUE,
                               #use_exact_dates = FALSE
                               ) {


  # TODO:
  # sensible parameter / argument checks, sensible defaults


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
      replace_uids = TRUE
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










