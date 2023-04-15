#' @title Loads the iDAI.field Categories
#' @description This function loads the iDAI.field categories with the default values.
#' @param libname The name of the library.
#' @param pkgname The name of the package.
#' @return A list of options.
#' @export
#' @examples
#' \dontrun{
#' idaifield_categories <- .onLoad("mylib", "idaifieldR")
#' }
.onLoad <- function(libname, pkgname) {
  # The options are set in a list.
  options(
    # The list contains a list of options.
    list(idaifield_categories = list(
      # The list of options contains the default values for the categories.
      layers = c("Layer", "Grave", "Burial", "Architecture", "Floor"),
      # The list of options contains the default values for the strict categories.
      layers_strict = c("Layer"),
      # The list of options contains the default values for the relations.
      relations = c("isDepictedIn", "isRecordedIn", "liesWithin",
                    "borders", "cuts", "depicts", "fills", "hasInstance",
                    "hasLayer", "hasMapLayer", "isAbove", "isAfter",
                    "isBefore", "isBelow", "isContemporaryWith", "isCutBy",
                    "isDepictedIn", "isFilledBy", "isLayerOf", "isMapLayerOf",
                    "isRecordedIn", "isSameAs", "liesWithin")
    )
    )
  )
}
