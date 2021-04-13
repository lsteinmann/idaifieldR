#' Title
#' @keywords internal
#' @param libname libname
#' @param pkgname pkgname
#'
.onLoad <- function(libname, pkgname) {
  options(
    list(idaifield_types = list(
      layers = c("Layer", "Grave", "Burial", "Architecture", "Floor"),
      layers_strict = c("Layer")
      )
      )
    )
}
