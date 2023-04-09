#' Converts coordinate list from idaifield to a matrix
#'
#' @param coordinates a list of the format that any coordinateslist has
#' in the iDAI.field 2 / Field Desktop database
#'
#' @return a matrix that displays the same coordinates
#'
#' @keywords internal
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
  coordmat <- matrix(nrow = length(coordinates), ncol = 3)
  for (i in seq_along(coordinates)) {
    coordmat[i, 1] <- unlist(coordinates[[i]][[1]])
    coordmat[i, 2] <- unlist(coordinates[[i]][[2]])
    if (length(coordinates[[i]]) == 3) {
      coordmat[i, 3] <- unlist(coordinates[[i]][[3]])
    } else {
      coordmat[i, 3] <- 0
    }
  }
  return(coordmat)
}


#' reformat the geometry of an iDAI.field resource
#'
#' @param geometry the list in `docs$resource$geometry` of `idaifield_...`-list
#'
#' @return the same data in a more handy format that can be processed with
#' tools like the sp-package to produce polygons etc.
#'
#' @seealso \code{\link{simplify_idaifield}}
#'
#'
#' @references
#' Field Desktop Client: \url{https://github.com/dainst/idai-field}
#'
#' @export
#'
#' @examples
#' test_2 <- list(type = "Polygon", coordinates = list(list(list(1), list(1)),
#' list(list(1), list(2)),
#' list(list(2), list(2)),
#' list(list(1), list(1))))
#'
#' reformat_geometry(test_2)
reformat_geometry <- function(geometry) {
  type <- geometry$type

  if (!is.null(type)) {
    if (type == "Point") {
      p_coords <- unlist(geometry$coordinates)
      if (length(p_coords) %% 2 == 0) {
        geometry$coordinates <- list(matrix(p_coords,
                                            ncol = 2))
        geometry$coordinates[[1]] <- cbind(geometry$coordinates[[1]], 0)
      } else {
        geometry$coordinates <- list(matrix(p_coords,
                                            ncol = 3))
      }

    } else if (type %in% c("Polygon", "LineString", "MultiPoint")) {
      geometry$coordinates <- list(convert_to_coordmat(geometry$coordinates))
    } else if (type %in% c("MultiPolygon", "MultiLineString")) {
      geometry$coordinates <- lapply(geometry$coordinates,
                                     function(x) convert_to_coordmat(x))
    }
  }
  return(geometry)
}
