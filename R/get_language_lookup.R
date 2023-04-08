#' Create a data.frame from a list of labels and descriptions from iDAI.field
#'
#' Helper to get_language_lookup()
#'
#'
#' @param fields_list A named list that contains one or two other
#' named lists ("label" and "description") with the translation / display
#' language of the respective internal value (i.e. the name of the list)
#' @param language
#'
#' @return a data frame with the column "var" and "label" containing the
#' value in var and its respective translation / display value in "label"
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' fields_list <- list("category" = list("label" = "Category"),
#'                     "identifier" = list("label" = "Name / ID (unique)",
#'                     "description" = "Description of the field"))
#' df <- extract_field_names(fields_list)
#' }
extract_field_names <- function(fields_list) {
  fields_list <- unlist(lapply(fields_list,
                               function (x) {
                                 try <- try(x$label, silent = TRUE)
                                 if (inherits(try, "try-error")) {
                                   NA
                                 } else {
                                   try
                                 }
                               }),
                        use.names = TRUE)
  # and reformat to df for later use
  fields_df <- data.frame("var" = names(fields_list), "label" = fields_list)

  fields_df <- fields_df[!is.na(fields_df$label), ]

  return(fields_df)
}

#' Prepare a Language List as a Lookup Table
#'
#' The function compiles a table of background values and their translations
#' in the language selected from the configuration supplied to it. Current
#' Configuration resources from the database obtained by `get_configuration()`
#' only contain canges made after the addition of the project configuration
#' editor in iDAI.field 3. You can obtain older language configurations with
#' `download_language_list()` from the iDAI.field GitHub repository.
#'
#'
#' @details Be aware: if two things have the same name
#' in the background of the database / project configuration but you use
#' different translations this will result in only one of the
#' translations being used.
#'
#' @param lang_list A list in the format used by iDAI.fields configuration,
#' containing a separate list for each language with its short
#' name (e.g. "en", "de") in which the "commons", "categories" etc. lists
#' are contained. Can be obtained with `get_configuration()`.
#' @param language Language short name that is to be extracted, e.g. "en",
#' defaults to "en"
#'
#' @return A data.frame that can serve as a lookup table, with the background
#' name in the "var" column, and the selected language in the "label" column.
#'
#' @export
#'
#' @seealso \code{\link{get_configuration}},
#' \code{\link{download_language_list}}
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#'                           project = "rtest",
#'                           pwd = "hallo")
#' config <- get_configuration(connection = conn)
#' lookup <- get_language_lookup(config$languages, language = "en")
#' }
get_language_lookup <- function(lang_list, language = "en") {
  # if any of the reversed results of grepl are true, we need to skip because
  # the names are not in language-list forma, e.g. "en", "de", "fr"
  # (the reverse/any combination is weird, but we have to reverse the matches
  # as any only returns any TRUE matches)
  if (any(!grepl("^[a-z]{2}$", names(lang_list)))) {
    stop("..in 'prep_language()': Language list is not in the correct format.")
  } else {
    lang_list <- lang_list[[language]]
  }

  if (length(lang_list) == 0) {
    stop("..in 'prep_language()': Language list is empty.
         Your configuration may not have custom language settings.")
  }

  names <- names(lang_list)
  result <- data.frame("var" = 1, "label" = 1)
  for (name in names) {
    if (name ==  "groups") {
      next
    }
    label_df <- extract_field_names(lang_list[[name]])

    check <- lapply(lang_list[[name]], check_for_sublist)
    check <- unlist(check)
    check <- any(check)

    if (check) {
      sublist <- unlist(lang_list[[name]], recursive = FALSE, use.names = FALSE)
      ind <- unlist(lapply(sublist, function(x) is.null(names(x))))
      ind <- which(ind)
      sublist <- sublist[-ind]
      sublist <- unlist(sublist, recursive = FALSE, use.names = TRUE)
      label_df_sec <- extract_field_names(sublist)
      label_df <- rbind(label_df, label_df_sec)
    }
    result <- rbind(result, label_df)
  }
  result <- result[-1, ]

  # reduce multiple values - Attention: if two things have the same name
  # in the background of the db but you use different translations
  # this will result in only one of the translations being used
  # I am leaving it here as a todo/note, but it is not a good idea.
  #result <- result[match(unique(result$var), result$var),]
  # reset rownames
  if (nrow(result) != 0) {
    rownames(result) <- 1:nrow(result)
  }
  result$var <- remove_config_names(result$var)

  return(result)
}
