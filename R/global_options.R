#' Title
#' @keywords internal
#' @param libname libname
#' @param pkgname pkgname
#'
.onLoad <- function(libname, pkgname) {
  options(
    list(idaifield_types = list(
      layers = c("Layer", "Grave", "Burial", "Architecture", "Floor"),
      layers_strict = c("Layer"),
      relations = c("isDepictedIn","isRecordedIn", "liesWithin",
                    "borders", "cuts","depicts", "fills","hasInstance",
                    "hasLayer","hasMapLayer", "isAbove","isAfter",
                    "isBefore","isBelow", "isContemporaryWith", "isCutBy",
                    "isDepictedIn","isFilledBy", "isLayerOf","isMapLayerOf",
                    "isRecordedIn", "isSameAs","liesWithin")
    )
    )
  )
}

getOption("idaifield_types")
