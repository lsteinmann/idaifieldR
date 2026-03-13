#' @title onLoad / onAttach
#' @param lib The name of the library.
#' @param pkg The name of the package.
.onAttach <- function(lib, pkg) {
  checked_idf <- check_idaifieldr_version(getNamespaceVersion('idaifieldR'))
  rm(checked_idf)
}
