#' @title Break down a List from a Checkbox Field to Onehot-Coded Values
#'
#' @description This function is a helper function to
#' [simplify_idaifield()] that takes a list from one of the
#' fields marked in the config as containing checkboxes and converts
#' the list to onehot-coded values.
#'
#' @param resource The resource to process (from an `idaifield_resources`-list).
#' @param fieldtypes A matrix of fields with the given inputType as
#' returned by [extract_inputtypes()]
#'
#' @returns The resource object with the values of checkboxes
#' separated into one-hot-coded versions.
#'
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()]
#' * Needs output of: [extract_inputtypes()] (Currently not working, though!)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ...
#' }
convert_to_onehot <- function(resource, fieldtypes) {
  # get the inputType list
  checkboxes <- fieldtypes[which(fieldtypes[, "inputType"] == "checkboxes"), ]

  if (!is.matrix(checkboxes)) {
    checkboxes_new <- matrix(nrow = 1, ncol = ncol(fieldtypes))
    checkboxes_new[1,] <- checkboxes
    colnames(checkboxes_new) <- names(checkboxes)
    checkboxes <- checkboxes_new
  }

  # find which fields actually belong to the resource type
  # correct_cat <- which(checkboxes[, "category"] == resource$category)
  # manually add Feature and Find type because of problems
  # wtf does that even mean
  # correct_cat <- c(correct_cat,
  #                  which(checkboxes[, "category"] %in% c("Feature", "Find")))
  # get the index of the resource that should be converted
  # i actually give up. for now.
  index_to_convert <- which(names(resource) %in% checkboxes[, "field"])

  # add campaign field manually
  index_to_convert <- c(index_to_convert, which(names(resource) == "campaign"))

  # loop over the index to replace the checkbox-variable
  # with one-hot-coded versions
  for (i in index_to_convert) {
    var_name <- names(resource[i])
    var <- resource[[i]]
    new_vars <- rep(TRUE, length(var))
    names(new_vars) <- paste(var_name, ".", var, sep = "")
    resource <- append(resource, new_vars)
  }
  # remove the old ones
  resource[index_to_convert] <- NULL
  return(resource)
}


#' @title Convert a List of Dimensions to Simpler Values
#'
#' @description This function breaks down a list of dimensions
#' (e.g. `dimensionLength`, `dimensionWidth`, etc.) from a single
#' resource (element) of an `idaifield_docs` or `idaifield_resources` object
#' and converts them to simple values.It is used as a helper function
#' for `simplify_idaifield()`.
#'
#' @param dimensionList A list of dimensions (e.g. `dimensionLength`,
#' `dimensionWidth`, etc.) from a single resource (element) of an
#' `idaifield_docs` or `idaifield_resources` object.
#' @param name character. The name of the corresponding dimension list.
#' Defaults to "dimension".
#'
#' @returns A list containing simple values for each measured dimension
#' from the list. If a range was entered, the function returns the mean
#' without further comment.
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()]
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' dimensionLength_new <- idf_sepdim(idaifield_resources[[1]]$dimensionLength, "dimensionLength")
#' }
idf_sepdim <- function(dimensionList, name = NULL) {
  if (is.null(name)) {
    stop("'idf_sepdim()' needs a name-argument.")
  }
  if (!is.list(dimensionList)) {
    stop("'idf_sepdim()' needs a dimensionList as used by Field Desktop resources as the first argument.")
  }
  dimno <- length(dimensionList)

  get_dim_value <- function(x) {
    if (is.null(x$value)) {
      if (!is.null(x$rangeMin)) {
        range <- c(x$rangeMin, x$rangeMax)
        value <- mean(range) / 10000
        names(value) <- "mean_"
        return(value)
      } else {
        unit <- x$inputUnit
        value <- x$inputValue
        if (unit == "m") {
          value <- value * 100
          return(value)
        } else if (unit == "mm") {
          value <- value / 10
          return(value)
        } else if (unit == "cm") {
          return(value)
        }
      }
    } else {
      value <- x$value / 10000
      return(value)
    }
  }

  dims <- unlist(lapply(dimensionList, FUN = get_dim_value))
  dim_names <- rep(name, length(dims))
  dim_names <- paste(dim_names, "_cm_", names(dims),
                 seq(from = 1, to = dimno, by = 1),
                 sep = "")
  names(dims) <- dim_names
  dims <- as.list(dims)

  return(dims)
}


#' @title Remove Everything Before the Colon in a Character Vector
#'
#' @description Removes everything before the first colon (including the colon)
#' in a character vector. Used for cleaning up category or field names that
#' have been produced using the *Project Configuration Editor* in Field Desktop.
#'
#' @param conf_names A character vector.
#' @param silent Should the message that duplicates were
#' detected be suppressed? Default is FALSE.
#'
#' @returns The same character vector with everything before
#' the first colon (including the colon) removed.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nameslist <- c(
#'   "relation.liesWithin",
#'   "relation.liesWithinLayer",
#'   "campaign.2022",
#'   "rtest:test",
#'   "pergamon:neuesFeld",
#'   "neuesFeld"
#' )
#' remove_config_names(nameslist, silent = FALSE)
#' }
remove_config_names <- function(conf_names = c("identifier", "configname:test", "test"),
                                silent = FALSE) {
  new_names <- gsub("^.*:", "", conf_names)

  tbl <- table(new_names)
  tbl <- tbl[tbl > 1]

  if (length(tbl) >= 1) {
    n_dupl <- length(tbl)
    msg <- paste0("Removal of configuration specific names produced ",
                  n_dupl,  " duplicate(s). See attributes() for more info.")
    if (!silent) {
      message(msg)
    }
  }
  result <- new_names
  attributes(result)$duplicate_names <- names(tbl)

  return(result)
}

#' @title Gather Fields with Multiple Language Values
#'
#' @description This function extracts the values for a preferred language
#' from a list containing values in multiple languages.
#'
#' @param input_list A list with character values containing (or not)
#' sublists for each language.
#' @param language The short name (e.g. "en", "de", "fr") of the language
#' that is preferred for the fields. Special value "all" (the default) can be
#' used to return a concatenated string of all available languages.
#' [gather_languages()] will select other available languages
#' in alphabetical order if the selected language is not available.
#' @param silent TRUE/FALSE: Should gather_languages() issue messages
#' and warnings?
#'
#' @returns A character vector containing the values in the preferred language.
#'
#' @export
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()]
#'
#' @examples
#' \dontrun{
#' input_list <- list(list("en" = "English text", "de" = "Deutscher Text"),
#'                    list("en" = "Another english text", "de" = "Weiterer dt. Text"))
#' gather_languages(input_list, language = "de")
#' }
gather_languages <- function(input_list, language = "all", silent = FALSE) {
  # if this has a sublist / more than one entry, it means that there is
  # more than one language
  has_list <- suppressMessages(check_for_sublist(input_list))
  if (has_list) {
    if (language == "all") {
      res <- lapply(input_list, function(x) {
        new <- na_if_empty(unlist(x, use.names = TRUE))
        new <- paste(paste0(names(new), ": ", new), collapse = "; ")
        return(new)
        })
      res <- unlist(res)
      return(res)
    }
    # try to get the selected language
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
        res_sec <- lapply(input_list,
                          function(x) na_if_empty(unlist(x[languages[i]])))
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



#' @title Translate a Dating Value from iDAI.field to a Positive or Negative Number
#'
#' @description This function takes a list containing a numerical year and a type of dating
#' (either "bce", "ce", or "bp") and returns the year as a number with a
#' positive or negative sign indicating whether the year is BCE or CE.
#' If the dating type is "bp", the year is subtracted from 1950
#' to get a BCE year.
#'
#' @param list A named list containing at least the following elements:
#' \describe{
#' \item{inputYear}{A numerical value representing a year.}
#' \item{inputType}{A character string indicating the type of dating
#' for the inputYear value. Must be one of "bce", "ce", or "bp".}
#' }
#'
#' @returns A numerical value representing the year, with a negative
#' sign indicating BCE and a positive sign indicating CE. The `warning`
#' attribute carries over possible warnings.
#'
#' @keywords internal
#'
#' @seealso [fix_dating()]
#'
#' @examples
#' \dontrun{
#' list <- list(inputYear = 100, inputType = "bce")
#' bce_ce(list)
#' }
bce_ce <- function(list) {
  if (is.list(list) && "inputType" %in% names(list)) {
    bce_ce <- list$inputType
    year <- abs(as.numeric(list$inputYear))
    if (bce_ce == "bce") {
      year <- 0 - year
    } else if (bce_ce == "ce") {
      year <- year
    } else if (bce_ce == "bp") {
      year <- 1950 - year # 1950 is the zero point / origin of "before present"
    } else {
      attributes(year)$warning <- "None of BCE/CE/BP given. Dates may be incorrect."
    }
    return(year)
  } else if (is.list(list) && "year" %in% names(list)) {
    year <- as.numeric(list$year)
    attributes(year)$warning <- "No inputType for Year set. (Legacy data.)"
    return(year)
  } else {
    year <- NA
    attributes(year)$message <- "Could not transform dates. Not a list."
    return(year)
  }
}

#' @title Reduce the Dating-list to *min*/*max*-Values
#'
#' @description Reformats the "dating"-list of any resource from an `idaifield_docs`-
#' or `idaifield_resources`-list to contain min and max dating and
#' additional info as well as the original values in the "comment"-element.
#'
#' @param dat_list A "dating"-list of any resource from an `idaifield_docs`-
#' or `idaifield_resources`-list.
#' @param use_exact_dates TRUE/FALSE: If TRUE and "exact" dating type is
#' present, sets the min and max dating to the value of the exact dating.
#' Default is FALSE.
#'
#' @returns A reformatted list containing min and max dating and additional
#' information as well as all original values in the "comment"-element. If
#' `use_exact_dates = TRUE` contains the value of the exact dating in both
#' *dating.min* and *dating.max*.
#'
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()]
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' dat_list <- list(list(type = "range",
#'                      begin = list(inputYear = 2000, inputType = "bce"),
#'                      end = list(inputYear = 2000, inputType = "ce")),
#'                 list(type = "exact",
#'                      begin = list(inputYear = 130, inputType = "bce"),
#'                      end = list(inputYear = 130, inputType = "bce")))
#' # Use the true min/max dating:
#' fix_dating(dat_list)
#' # use the available exact dating:
#' fix_dating(dat_list, use_exact_dates = TRUE)
#'}
fix_dating <- function(dat_list, use_exact_dates = FALSE) {

  if (!is.list(dat_list)) {
    message("Not a list.")
    return(NA)
  }

  dat_min <- lapply(dat_list, function(x) unlist(bce_ce(x$begin)))
  dat_max <- lapply(dat_list, function(x) unlist(bce_ce(x$end)))

  warnings_min <- unlist(lapply(dat_min, function(x) attributes(x)))
  warnings_max <- unlist(lapply(dat_max, function(x) attributes(x)))

  new_dat_min <- suppressWarnings(min(unlist(dat_min), na.rm = TRUE))
  new_dat_max <- suppressWarnings(max(unlist(dat_max), na.rm = TRUE))

  dat_type <- unlist(lapply(dat_list, function(x) na_if_empty(x$type)))

  if (use_exact_dates) {
    ex_date <- dat_type == "exact"
    if (any(ex_date)) {
      new_dat_max <- unlist(dat_max)[ex_date]
      new_dat_min <- new_dat_max
      dat_type <- "exact"
    }
  }

  new_dat_type <- ifelse((length(dat_type) > 1), "multiple", dat_type)
  new_dat_min <- ifelse(is.infinite(new_dat_min), NA, new_dat_min)
  new_dat_max <- ifelse(is.infinite(new_dat_max), NA, new_dat_max)

  dat_uncertain <- unlist(lapply(dat_list, function(x) x$isUncertain))
  if (all(is.null(dat_uncertain))) {
    dat_uncertain <- FALSE
  } else {
    dat_uncertain <- any(dat_uncertain)
  }

  dat_complete <- lapply(dat_list,
                         function(x) paste(unlist(x, use.names = TRUE),
                                           collapse = "; "))
  dat_complete <- paste0("dating list ", seq(1:length(dat_complete)), ": ",
                         dat_complete, collapse = "; ")

  dat_source <- unlist(lapply(dat_list, function(x) na_if_empty(x$source)))

  dat_list <- list(min = new_dat_min, max = new_dat_max,
                   type = new_dat_type, uncertain = dat_uncertain,
                   source = dat_source, complete = dat_complete)
  if(any(c(length(warnings_min), length(warnings_max)) >= 1)) {
    warnings <- list(warnings = paste("min:", warnings_min, "; max:", warnings_max))
    dat_list <- append(dat_list, warnings)
  }

  names(dat_list) <- paste0("dating.", names(dat_list))
  return(dat_list)
}

#' Handle a `date` Input Field from an iDAI.field Resource
#'
#' Flattens a single `date`-type field value from an iDAI.field resource into
#' a named list with two elements: `<name>.start` and `<name>.end`. Handles
#' both the legacy format (a plain character string) and the current format
#' (a list with `value`, optional `endValue`, and `isRange`).
#'
#' Date strings are returned exactly as stored in the database — no parsing,
#' type conversion, or format normalisation is applied. Possible formats
#' include `"DD.MM.YYYY"`, `"DD.MM.YYYY HH:MM"`, `"MM.YYYY"`, and `"YYYY"`.
#'
#' For the legacy two-field format (`beginningDate` / `endDate` as separate
#' top-level keys in the resource), use [handle_legacy_date_range_fields()] on
#' the whole resource before per-field dispatch.
#'
#' @param value The value of a single `date`-type field from a resource, i.e.
#' `resource$date` or `resource$restorationDate`. Either a character string
#' (legacy single-field format) or a list with at minimum a `value` element
#' and an `isRange` logical (current format).
#' @param name Character. The name of the field being processed (e.g.
#' `"date"`, `"restorationDate"`). Used to name the output elements as
#' `<name>.start` and `<name>.end`.
#'
#' @returns A named list with two elements:
#' \describe{
#'   \item{<name>.start}{The start date as a character string.}
#'   \item{<name>.end}{The end date as a character string, or `NA` if the
#'   field is not a range.}
#' }
#'
#' @export
#'
#' @seealso
#' * [handle_legacy_date_range_fields()] for the legacy two-field format.
#' * [simplify_single_resource()] which dispatches to this function.
#'
#' @examples
#' \dontrun{
#' # Current format, single date
#' handle_date_input(list(value = "12.03.2026", isRange = FALSE), "date")
#'
#' # Current format, date range with time
#' handle_date_input(
#'   list(value = "19.08.2017 17:25", endValue = "20.08.2017 11:09", isRange = TRUE),
#'   "date"
#' )
#'
#' # Legacy plain string
#' handle_date_input("12.03.2026", "date")
#'
#' # Named after a custom date field
#' handle_date_input(list(value = "2025", isRange = FALSE), "restorationDate")
#' }
handle_date_input <- function(dateInput, name) {
  start_key <- paste0(name, ".start")
  end_key   <- paste0(name, ".end")

  # Legacy format: plain character string, no range possible.
  if (is.character(dateInput)) {
    result <- list(dateInput, NA)
    names(result) <- c(start_key, end_key)
    return(result)
  }

  if (is.list(dateInput)) {
    if ("value" %in% names(dateInput)) {
      start_date <- dateInput$value
    } else {
      # A dateInput with a range can have an end without a beginning.
      start_date <- NA
    }
    result <- list(
      start_date,
      if (isTRUE(dateInput$isRange)) dateInput$endValue else NA
    )
    names(result) <- c(start_key, end_key)
    return(result)
  }

  warning("handle_date_input(): unexpected input format, returning NA.")
  result        <- list(NA, NA)
  names(result) <- c(start_key, end_key)
  return(result)
}

#' Handle a `dropdownRange` Input Field from an iDAI.field Resource
#'
#' Flattens a single `dropdownRange`-type field value from an iDAI.field
#' resource into a named list with two elements: `<name>.start` and
#' `<name>.end`. If only the start value exists, both `<name>.start` and
#' `<name>.end` are set to the start value.
#'
#' @param dropdownRangeInput The value of a single `dropdownRange`-type field
#' from a resource, i.e. `period` from the default Configuration. Expects a
#' list with at minimum a `value` element and optionally an `endValue`.
#' @param name Character. The name of the field being processed (e.g.
#' `"period"`). Used to name the output elements as `<name>.start` and
#' `<name>.end`.
#'
#' @returns A named list with two elements:
#' \describe{
#'   \item{<name>.start}{The start value as a character string.}
#'   \item{<name>.end}{The end value as a character string, or the start
#'   value if no endValue was found.}
#' }
#' Unexpected input formats return `NA` for both values.
#'
#' @export
#'
#' @seealso
#' * [simplify_idaifield()] which dispatches to this function.
#'
#' @examples
#' \dontrun{
#' handle_dropdownrange_input(list(value = "Classical"), "period")
#'
#' # Current format, date range with time
#' handle_date_input(
#'   list(value = "Classical", endValue = "Hellenistic"),
#'   "period"
#' )
#' }
handle_dropdownrange_input <- function(dropdownRangeInput, name) {
  start_key <- paste0(name, ".start")
  end_key   <- paste0(name, ".end")

  if (is.list(dropdownRangeInput)) {
    if ("value" %in% names(dropdownRangeInput)) {
      start_value <- dropdownRangeInput$value
    } else {
      start_value <- NA
    }
    if ("endValue" %in% names(dropdownRangeInput)) {
      end_value <- dropdownRangeInput$endValue
    } else {
      end_value <- start_value
    }
    result <- list(start_value, end_value)
    names(result) <- c(start_key, end_key)
    return(result)
  }

  warning("handle_dropdownrange_input(): unexpected input format, returning NA.")
  result        <- list(NA, NA)
  names(result) <- c(start_key, end_key)
  return(result)
}

#' Update Legacy Two-Field Date Format in an iDAI.field Resource
#'
#' Some older iDAI.field resources store date ranges as two separate top-level
#' fields — `beginningDate` and `endDate` — rather than a single `date` list.
#' Resources in Field Desktop are only updated to the new format when they are
#' actively worked on and saved. This function detects those fields and
#' brings them into the expected, current format, removing the originals.
#'
#' Resources without both `beginningDate` and `endDate` are returned unchanged.
#' If only one of the two fields is present, the other is set to `NA`.
#'
#'
#' @param resource A single resource (one element from an
#' `idaifield_resources` list).
#'
#' @returns The resource with `beginningDate` and `endDate` removed and
#' replaced by a `date`-list to be handled by [handle_date_input()].
#' Returned unchanged if neither field is present.
#'
#' @export
#'
#' @seealso
#' * [handle_date_input()] for the current and legacy single-field formats.
#' * [simplify_single_resource()] which calls this as a pre-processing step.
#'
#' @examples
#' \dontrun{
#' resource <- list(
#'   identifier    = "legacyResource",
#'   category      = "Feature",
#'   beginningDate = "12.03.2026",
#'   endDate       = "13.03.2026"
#' )
#' handle_legacy_date_fields(resource)
#' }
handle_legacy_date_range_fields <- function(resource) {
  has_begin <- "beginningDate" %in% names(resource)
  has_end   <- "endDate"       %in% names(resource)

  if (!has_begin && !has_end) {
    return(resource)
  }

  new_date <- list(
    value = if (has_begin) resource$beginningDate else NA,
    isRange = has_end
  )
  if (has_end) {
    new_date <- append(
      new_date,
      list(endValue = resource$endDate)
    )
  }

  # Remove legacy fields and append normalised ones.
  resource$beginningDate <- NULL
  resource$endDate       <- NULL
  resource$date          <- new_date

  return(resource)
}
