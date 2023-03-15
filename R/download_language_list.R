#' Download a Language-List from GitHub
#'
#' This function downloads language lists from the idai-field GitHub-repository
#' and can be used to supply additional lists to `get_language_lookup()`.
#'
#'
#' @param project name of the project for which the language files should be
#' downloaded; case sensitive! Has to match the name in the Language-file
#' exactly. If default ("core") is used, the common language file from the core
#' library will be downloaded.
#' @param language Language short name that is to be extracted, e.g. "en",
#' defaults to "en"
#'
#' @return a list that can be processed with `get_language_lookup()`
#' @export
#'
#' @examples
#' \dontrun{
#' lang_list <- download_language_list(language = "de")
#' }
download_language_list <- function(project = "core",
                                   language = "en") {

  base_url <- "https://raw.github.com/dainst/idai-field/master/core/config/"

  if (project != "core") {
    project <- paste0(toupper(substr(project, 1, 1)),
                      substr(project, 2, nchar(project)))
    lang_url <- paste0(base_url, "Language-", project, ".", language, ".json")
  } else {
    lang_url <- paste0(base_url, "Core/Language.", language, ".json")
  }
  #TODO: would nee jsonlite as dependency
  lang_list <- list(jsonlite::read_json(lang_url))
  names(lang_list) <- language

  return(lang_list)
}