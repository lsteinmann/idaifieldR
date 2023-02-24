#' prep_language_list(): Prepare a Language List as a Lookup Table
#'
#' @param lang_list A list in the format used by iDAI.fields configuration,
#' containing a separate list for each language with its short
#' name (e.g. "en", "de") in which the "commons", "categories" etc. lists
#' are contained.
#' @param language Language short name that is to be extracted, e.g. "en",
#' defaults to "en"
#'
#' @return A data.frame that can serve as a lookup table, with the background
#' name in the "var" column, and the selected language in the "label" column.
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#'                           user = "R", pwd = "hallo")
#' config <- get_configuration(connection = conn, projectname = "rtest")
#' lookup <- prep_language_list(config$languages, language = "en")
#' }


prep_language_list <- function(lang_list, language = "en") {
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

  # Extract the data from various sub-lists ...
  commons <- unlist(lapply(lang_list$commons,
                           function (x) x$label),
                    use.names = TRUE)
  # and reformat to df for later use
  commons <- data.frame("var" = names(commons), "label" = commons)

  # categories work the same as commons
  categories <- unlist(lapply(lang_list$categories,
                              function (x) x$label),
                       use.names = TRUE)
  categories <- data.frame("var" = names(categories),
                           "label" = categories)

  # fields need to be treated slightly different, as they are more
  # nested that the other two types - first we get the fields from inside
  # all categories
  fields <- lapply(lang_list$categories,
                   function (x) lapply(x$fields,
                                       function(y) y$label))

  # then we get the original values from the db backend
  fields_int <- unlist(lapply(fields,
                              function(x) names(x)),
                       use.names = FALSE)
  # and the language-specific labels
  fields_labels <- unlist(fields, use.names = FALSE)

  # store in df again
  fields <- data.frame("var" = fields_int,
                       "label" = fields_labels)

  # bind the results in one data.frame
  result <- rbind(commons, categories, fields)
  # reduce multiple values - Attention: if two things have the same name
  # in the background of the db but you use different translations
  # this will result in only one of the translations being used
  result <- result[match(unique(result$var), result$var),]
  # reset rownames
  rownames(result) <- 1:nrow(result)
  return(result)
}
