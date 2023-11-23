#' Check Version of idaifieldR
#'
#' Checks if a new version of idaifieldR is available (runs on attach).
#'
#' @param installed_version version of idaifieldR currently in use
#'
#' @return nothing
#'
#' @export
#'
#' @examples
#' \dontrun{
#' check_idaifieldr_version(packageVersion('idaifieldR'))
#' }
check_idaifieldr_version <- function(installed_version = getNamespaceVersion('idaifieldR')) {
  repo <- 'lsteinmann/idaifieldR'
  gh <- try(suppressWarnings(
    jsonlite::read_json(paste0('https://api.github.com/repos/',
                               repo, '/releases/latest'))
    ),
            silent = TRUE)
  if (!inherits(gh, "try-error")) {
    new_version <- gsub('v', '', gh$tag_name)
    installed_version <- as.character(installed_version)
    if (installed_version != new_version) {
      msg <- paste0('A new version of idaifieldR is available on GitHub, ',
                    'see: ', gh$html_url, '\n',
                    '    You can install it with: ',
                    'remotes::install_github("', repo, '@',
                    gh$tag_name, '")')
      packageStartupMessage(msg)
    }
  }
}
