#' @title onLoad / onAttach
#' @param lib The name of the library.
#' @param pkg The name of the package.
.onLoad <- function(lib, pkg) {
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

.onAttach <- function(lib, pkg) {
  check_idaifieldr_version(getNamespaceVersion('idaifieldR'))
}
