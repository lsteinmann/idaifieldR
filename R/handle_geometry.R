#' Convert a List to a JSON-String
#'
#' You can use `sf::st_read(geojson_string, quiet = TRUE)` to convert this to
#' a geometry you can plot in R.
#'
#' @param x A list that should be converted (back) to a JSON string.
#'
#' @seealso
#' * This function is used in: [simplify_idaifield()]
#'
#' @return A JSON-string
#' @export
#' @keywords internal
maybe_to_json <- function(x) {
  if (is.null(x)) {
    return(NA)
  }
  json <- jsonlite::toJSON(x, auto_unbox = TRUE)
  return(json)
  #geom <- tryCatch(
  #  sf::st_read(geojson_string, quiet = TRUE),
  #  error = function(e) {
  #    warning("Could not parse geometry: ", conditionMessage(e))
  #    NA
  #  }
  #)
  #return(geom)
}
