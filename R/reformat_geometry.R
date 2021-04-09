#' Converts a polygon list to a matrix
#'
#' @param geometry_polygon a list of the format that any polygon has
#' in the iDAI.field 2 database
#'
#' @return a matrix that displays the same polygon
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
convert_polygon <- function(geometry_polygon) {
  if (length(geometry_polygon) == 1) {
    geometry_polygon <- geometry_polygon[[1]]
  }
  coordmat <- matrix(nrow = length(geometry_polygon), ncol = 2)
  for (i in seq_along(geometry_polygon)) {
    coordmat[i, 1] <- unlist(geometry_polygon[[i]][[1]])
    coordmat[i, 2] <- unlist(geometry_polygon[[i]][[2]])
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
    if (type == "Polygon") {
      geometry$coordinates <- list(convert_polygon(geometry$coordinates))
    } else if (type == "MultiPolygon") {
      geometry$coordinates <- lapply(geometry$coordinates,
                                     function (x) convert_polygon(x))
    } else if (type == "Point" | type == "LineString") {
      geometry$coordinates <- c(unlist(geometry$coordinates))
    } else if (type == "MultiPoint" | type == "MultiLineString") {
      geometry$coordinates <- lapply(geometry$coordinates, unlist)
    }
  }
  return(geometry)
}
