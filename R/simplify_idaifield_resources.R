#' Simplify a Single Resource from an iDAI.field / Field Desktop Database
#'
#' Helper function to [simplify_idaifield()]. Transforms a single resource
#' from an `idaifield_resources` list into a flatter, more R-friendly
#' structure.
#'
#' @param resource One element from an `idaifield_resources` list.
#' @param index A data.frame as returned by [make_index()] or
#' [get_field_index()]. Required for UUID replacement and layer detection.
#' @param config An `idaifield_config` object as returned by
#' [get_configuration()]. Required when `find_layers = TRUE`.
#' @param replace_uids logical. Should UUIDs in relations be replaced with
#' human-readable identifiers from `index`? Default is TRUE.
#' @param find_layers logical. Should the containing layer be detected and
#' added as `relation.liesWithinLayer`? Default is TRUE.
#' @param keep_geometry logical. Should geometry be kept as a GeoJSON string?
#' Default is TRUE.
#' @param silent logical. Should messages be suppressed? Default is FALSE.
#'
#' @returns A single resource with relations flattened, geometry handled,
#' and simple fields unlisted to vectors.
#'
#' @keywords internal
#'
#' @seealso [simplify_idaifield()], [fix_relations()], [find_layer()]
#'
#' @examples
#' \dontrun{
#' index <- make_index(docs)
#' config <- get_configuration(conn)
#' simpler <- simplify_single_resource(docs[[1]],
#'   index = index,
#'   config = config,
#'   keep_geometry = FALSE
#' )
#' }
simplify_single_resource <- function(resource,
                                     index = NULL,
                                     inputtypes = NULL,
                                     replace_uids = TRUE,
                                     keep_geometry = TRUE,
                                     silent = FALSE) {

  stopifnot(is.logical(keep_geometry))
  stopifnot(is.logical(replace_uids))
  stopifnot(is.logical(silent))

  id <- resource$identifier
  if (is.null(id)) {
    stop("Not in valid format, please supply a single element from an 'idaifield_resources' list.")
  }

  # ----- Legacy data fix
  # In older versions of iDAI.field, the category field was called "type".
  # Rename retroactively so downstream code only needs to handle "category".
  # This actually should be useless by now, since I use type_to_category
  # everywhere I am getting docs lists from the database.
  if (is.null(resource$category)) {
    message("This should not have happened: 'type' still present in resource!")
    resource$category <- resource$type
    resource$type <- NULL
  }
  # In older versions of iDAI.field, "date" was recorded in the default
  # configuration for some resources as beginningDate and endDate, which is
  # migrated by Field Desktop when a resource is saved. Since not everything
  # is expected to be in the "new" dateInput format, we need to handle these
  # if they exist at all:
  resource <- handle_legacy_date_range_fields(resource)

  # ----- Flatten date fields
  # into two names vectors with fieldName.start/.end as prefix
  dateInputs <- inputtypes$fieldname[which(inputtypes$inputType == "date")]
  for (dateInput in dateInputs) {
    if (dateInput %in% names(resource)) {
      new_dates <- handle_date_input(resource[[dateInput]], dateInput)
      resource[[dateInput]] <- NULL
      resource <- append(resource, new_dates)
    }
  }

  # ----- Flatten relations into named vectors with "relation." prefix
  # e.g. relations$liesWithin -> relation.liesWithin = c("Befund 1")
  resource <- fix_relations(resource, replace_uids = replace_uids, index = index)

  # ----- Handle geometry
  # Geometry is kept as a GeoJSON string for maximum compatibility.
  # To convert to an sf object: sf::st_read(resource$geometry)
  if (keep_geometry && !is.null(resource$geometry)) {
    resource$geometry <- maybe_to_json(resource$geometry)
  } else {
    resource$geometry <- NULL
  }

  # TODO: language selection
  # Multilingual fields are lists with named elements like list(de = "...", en = "...").
  # Selecting a single language requires distinguishing these from other list fields.
  # Not yet implemented — all languages are kept for now.
  # ----- Select the specified language
  #resource <- lapply(resource, function(input) {
  #  fix_language(input, language = language)
  #})


  # ----- Unlist simple fields to vectors
  # Fields that do not contain nested lists are unlisted for easier handling
  # in data frames. Fields with sub-lists (e.g. composite fields) are left as-is.
  resource <- lapply(resource, function(x) {
    if (!check_for_sublist(x)) {
      unlist(x)
    } else {
      x
    }
  })

  return(resource)
}


#' Simplify a List Imported from an iDAI.field / Field Desktop Database
#'
#' Takes a list as returned by [get_idaifield_docs()], [idf_query()],
#' [idf_index_query()], or [idf_json_query()] and transforms it into a
#' flatter, more R-friendly structure.
#'
#' Relations are flattened into named vectors with a `relation.`-prefix
#' (e.g. `relation.liesWithin`). UUIDs in relations are replaced with
#' human-readable identifiers. Geometry is kept as a GeoJSON string if
#' `keep_geometry = TRUE`.
#'
#' Note: If you are working with a subset of resources (e.g. from
#' [idf_query()]), you should supply the `index` of the *complete* project
#' database, not just the subset — otherwise UUID replacement will be
#' incomplete.
#'
#' @param resources An `idaifield_docs` or `idaifield_resources` list as
#' returned by [get_idaifield_docs()], [idf_query()], [idf_index_query()],
#' or [idf_json_query()].
#' @inheritParams simplify_single_resource
#'
#' @returns An `idaifield_simple` list with the same resources in a flatter
#' format, with `connection`, `projectname`, and `language` stored as
#' attributes.
#'
#' @export
#'
#' @seealso
#' * [get_idaifield_docs()] to import resources from the database
#' * [make_index()] and [get_field_index()] for building an index
#' * [get_configuration()] for the project configuration
#' * [fix_relations()] for relation flattening
#' * [find_layer()] for layer detection
#' * [idaifield_as_matrix()] for converting the result to a matrix
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "localhost", project = "rtest", pwd = "hallo")
#' docs <- get_idaifield_docs(connection = conn)
#' simple <- simplify_idaifield(docs)
#' }
simplify_idaifield <- function(resources,
                               index = NULL,
                               config = NULL,
                               language = "all",
                               keep_geometry = FALSE,
                               find_layers = FALSE,
                               silent = FALSE,
                               ...) {

  # ----- Handle deprecated parameters passed via ...
  deprecated <- list(...)
  if ("uidlist" %in% names(deprecated)) {
    warning("'uidlist' has been renamed to 'index'. Please update your code.")
    if (is.null(index)) {
      index <- deprecated[["uidlist"]]
    }
  }
  for (param in c("remove_config_names", "use_exact_dates", "spread_fields", "replace_uids", "find_layers")) {
    if (param %in% names(deprecated)) {
      warning(paste0("'", param, "' is deprecated and has no effect. Please update your code."))
    }
  }

  # ----- Check input structure
  if (inherits(resources, "idaifield_simple")) {
    message("'resources' is already an 'idaifield_simple', did nothing.")
    return(resources)
  }
  resources <- maybe_unnest_docs(resources)
  if (!inherits(resources, "idaifield_resources")) {
    stop("'resources' is not an 'idaifield_resources' list as returned by get_idaifield_docs().")
  }

  # ----- Build index if not supplied
  if (is.null(index)) {
    if (!silent) message("No 'index' supplied, generating from this list.")
    index <- make_index(resources)
  }

  # ----- Get config if not supplied
  if (is.null(config)) {
    conn <- attr(resources, "connection")
    config <- get_configuration(conn)
  } else if (!inherits(config, "idaifield_config")) {
    stop("'config' must be an 'idaifield_config' object as returned by get_configuration().")
  }

  # ----- Find layers vectorized across all resources (faster than per-resource)
  layer_categories <- c("Feature", names(config$categories$Feature$trees))
  liesWithinLayer <- find_layer(
    names(resources),
    index,
    layer_categories = layer_categories
  )

  inputtypes <- parse_field_inputtypes(config)

  # ----- Apply per-resource simplification
  idaifield_simple <- lapply(resources, function(x) {
    new_res <- simplify_single_resource(
      x,
      index = index,
      inputtypes = inputtypes[which(inputtypes$category == x$category),],
      replace_uids = TRUE,
      keep_geometry = keep_geometry,
      silent = silent
    )
    lwl <- liesWithinLayer[names(liesWithinLayer) == x$identifier]
    if (length(lwl) > 0) {
      names(lwl) <- "relation.liesWithinLayer"
      new_res <- append(new_res, lwl)
    }
    return(new_res)
  })

  idaifield_simple <- structure(idaifield_simple, class = "idaifield_simple")
  attr(idaifield_simple, "connection")   <- attr(resources, "connection")
  attr(idaifield_simple, "projectname")  <- attr(resources, "projectname")

  return(idaifield_simple)
}
