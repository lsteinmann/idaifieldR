#' @title Break down a List from a Checkbox Field to Onehot-Coded Values
#'
#' @description This function is a helper function to
#' [simplify_idaifield()] that takes a list from one of the
#' fields marked in the config as containing checkboxes and converts
#' the list to onehot-coded values.
#'
#' @param resource The resource to process (from an `idaifield_resources`-list).
#' @param fieldtypes A matrix of fields with the given inputType as
#' returned by [get_field_inputtypes()]
#'
#' @returns The resource object with the values of checkboxes
#' separated into one-hot-coded versions.
#'
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()]
#' * Needs output of: [get_field_inputtypes()]
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
#' @description This function removes everything before the first
#' colon (including the colon) in a character vector.
#' It is used as a helper function for `simplify_idaifield()`.
#'
#' @param conf_names A character vector.
#' @param silent Should the message that duplicates were
#' detected be suppressed? Default is FALSE.
#'
#' @returns The same character vector with everything before
#' the first colon (including the colon) removed.
#'
#' @seealso
#' * This function is used by: [simplify_idaifield()], [get_field_index()]
#' and [get_uid_list()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nameslist <- c("relation.liesWithin", "relation.liesWithinLayer",
#' "campaign.2022", "rtest:test", "pergamon:neuesFeld")
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
