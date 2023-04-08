#' Break down a list from a checkbox field to onehot-coded values
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param resource A list from one of the measurement fields
#' (dimensionLength, dimensionWidth, etc.) from a single resource (element).
#' @param config A configuration list as returned by `get_configuration()`
#'
#' @return The resource object with the checkboxes seperated
#'
#' @keywords internal
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


#' Break down a list from a dimension field to a single value
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param dimensionList A list from one of the measurement fields
#' (dimensionLength, dimensionWidth, etc.) from a single resource (element).
#' @param name The name of the corresponding dimension List.
#'
#' @return A list containing simple values for each measured dimension from
#' the list; note: if a range was entered, it returns the mean without further
#' comment.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' dimensionLength_new <- idf_sepdim(idaifield_resources[[1]]$dimensionLength,
#' "dimensionLength")
#' }
idf_sepdim <- function(dimensionList, name = "dimensionLength") {
  dimno <- length(dimensionList)
  get_dim_value <- function(x) {
    if (is.null(x$value)) {
      if (!is.null(x$rangeMin)) {
        range <- c(x$rangeMin, x$rangeMax)
        value <- mean(range) / 10000
        # set name here for later add underscore for later naming
        names(value) <- "mean_"
        return(value)
      } else {
        # And then we need to do unit conversion...
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

  # get named vector with all values, avoid name when normal measurement
  dims <- unlist(lapply(dimensionList, FUN = get_dim_value))
  names <- rep(name, length(dims))
  names <- paste(names, "_cm_", names(dims),
                 seq(from = 1, to = dimno, by = 1),
                 sep = "")
  names(dims) <- names
  dims <- as.list(dims)
  return(dims)
}

#' Remove everything before the : in a character vector
#'
#' This function is a helper to `simplify_single_resource()`.
#'
#' @param nameslist a character vector
#'
#' @return same character vector without everything before
#' the ":" including the ":"
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' nameslist <- c("relation.liesWithin","relation.liesWithinLayer",
#' "campaign.2022","milet:test")
#' nameslist <- remove_config_names(nameslist)
#' nameslist
#' }
remove_config_names <- function(nameslist = c("identifier", "configname:test")) {
  nameslist <- gsub("^.*:", "", nameslist)
  return(nameslist)
}

#' Gather multilanguage fields
#'
#' @param input_list a list with character values containing (or not)
#' sublists for each language
#' @param language the short name (e.g. "en", "de", "fr") of the language that
#' is preferred for the fields, defaults to english ("en")
#' @param silent TRUE/FALSE: Should gather_languages()
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

#' Translate a list for one dating value from iDAI.field to a positive or negative number
#'
#' (Field does save numbers in this format, but apparently not all of them.
#' This corrects for wrong numbers. Numbers bp/before present are subtracted
#' from 1950 to get dates BCE.)
#'
#' @param list A named list containing (at least): inputYear (number),
#' and inputType ("bce", "ce", "bp")
#'
#' @return The year as a number, negative when BCE, positive when CE
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' list <- list(inputYear = 100, inputType = "bce")
#' bce_ce(list)
#' }
#'
bce_ce <- function(list) {
  if (is.list(list)) {
    year <- abs(as.numeric(list$inputYear))
    bce_ce <- list$inputType
    if (bce_ce == "bce") {
      year <- 0 - year
    } else if (bce_ce == "ce") {
      year <- year
    } else if (bce_ce == "bp") {
      year <- 1950 - year # 1950 is the zero point / origin of "before present"
    } else {
      stop("None of BCE/CE/BP given.")
    }
    return(year)
  } else {
    return(NA)
  }
}


#' Reduce the Dating-list to min/max-values
#'
#' Note: This function will evaluate all begin and end values for the
#' dating of the resource object and evaluate only their min and max values!
#'
#' @param dat_list The "dating"-list of any resource from
#' an `idaifield_...`-list
#'
#' @return a reformatted list, containing min and max dating and additional
#' info as well as the original values in the "comment"-element
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' dat_list <- list(type = "range",
#'                  begin = list(inputYear = 2000, inputType = "bce"),
#'                  end = list(inputYear = 2000, inputType = "ce"))
#' fix_dating(dat_list)
#' }
fix_dating <- function(dat_list) {
fix_dating <- function(dat_list, use_exact_dates = FALSE) {

  if (!is.list(dat_list)) {
    message("Not a list.")
    return(NA)
  }

  dat_min <- lapply(dat_list, function(x) unlist(bce_ce(x$begin)))
  dat_max <- lapply(dat_list, function(x) unlist(bce_ce(x$end)))



  new_dat_min <- suppressWarnings(min(unlist(dat_min), na.rm = TRUE))
  new_dat_max <- suppressWarnings(max(unlist(dat_max), na.rm = TRUE))

  dat_type <- unlist(lapply(dat_list, function(x) x$type))

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

  dat_source <- unlist(lapply(dat_list, function(x) x$source))

  dat_list <- list(min = new_dat_min, max = new_dat_max,
                   type = new_dat_type, uncertain = dat_uncertain,
                   source = dat_source, complete = dat_complete)

  names(dat_list) <- paste0("dating.", names(dat_list))
  return(dat_list)
}
