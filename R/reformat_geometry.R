#' Converts coordinate list from idaifield to a matrix
#'
#' @param coordinates a list of the format that any coordinateslist has
#' in the iDAI.field 2 database
#'
#' @return a matrix that displays the same coordinates
#'
#' @examples
#' \dontrun{
#' test_2 <- list(type = "Polygon", coordinates = list(list(list(1), list(1)),
#' list(list(1), list(2)),
#' list(list(2), list(2)),
#' list(list(1), list(1))))
#'
#' convert_polygon(test_2$coordinates)
#' }
convert_to_coordmat <- function(coordinates) {
  if (length(coordinates) == 1) {
    coordinates <- coordinates[[1]]
  }
  coordmat <- matrix(nrow = length(coordinates), ncol = 2)
  for (i in seq_along(coordinates)) {
    coordmat[i, 1] <- unlist(coordinates[[i]][[1]])
    coordmat[i, 2] <- unlist(coordinates[[i]][[2]])
  }
  return(coordmat)
}


#' reformat the geometry of an iDAI.field 2 resource
#'
#' @param geometry the list in docs$resource$geometry
#'
#' @return the same data in a more handy format that can be processed with
#' tools like the sp-package to produce polygons etc.
#'
#' @export
#' @keywords internal
#'
#' @examples
#' test_2 <- list(type = "Polygon", coordinates = list(list(list(1), list(1)),
#' list(list(1), list(2)),
#' list(list(2), list(2)),
#' list(list(1), list(1))))
#'
#' reformat_geometry(test_2)
reformat_geometry <- function (geometry) {
  type <- geometry$type

  if (!is.null(type)) {
    if (type == "Point") {
      geometry$coordinates <- list(matrix(unlist(geometry$coordinates),
                                          ncol = 2))
    } else if (type %in% c("Polygon", "LineString", "MultiPoint")) {
      geometry$coordinates <- list(convert_to_coordmat(geometry$coordinates))
    } else if (type %in% c("MultiPolygon", "MultiLineString")) {
      geometry$coordinates <- lapply(geometry$coordinates,
                                     function (x) convert_to_coordmat(x))
    }
  }
  return(geometry)
}
