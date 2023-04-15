#' Converts Coordinate List from iDAI.field to a Matrix
#'
#' @param coordinates a list of the format that any coordinates list has
#' in the iDAI.field 2 / Field Desktop database.
#'
#' @returns a matrix that displays the same coordinates.
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
  # if the length of the coordinates is 1, then the coordinates are in a list of lists
  if (length(coordinates) == 1) {
    # extract the coordinates from the list of lists
    coordinates <- coordinates[[1]]
  }
  # create a matrix with the same number of rows as the coordinates and 3 columns
  coordmat <- matrix(nrow = length(coordinates), ncol = 3)
  # for each coordinate
  for (i in seq_along(coordinates)) {
    # add first dim
    coordmat[i, 1] <- unlist(coordinates[[i]][[1]])
    # add second dim
    coordmat[i, 2] <- unlist(coordinates[[i]][[2]])
    if (length(coordinates[[i]]) == 3) {
      # if exists, add z dim
      coordmat[i, 3] <- unlist(coordinates[[i]][[3]])
    } else {
      # it f it doesnt, add 0
      coordmat[i, 3] <- 0
    }
  }
  return(coordmat)
}



#' Reformat the Geometry of a single iDAI.field / Field Desktop resource
#'
#' @param geometry The list in `resource$geometry` of an `idaifield_docs`-
#' or `idaifield_resources`-list.
#'
#' @return The geometry of the resource in a more usable format that can
#' be processed with tools like [sp::SpatialPoints()] etc. to work with
#' spatial data. The geometry is returned as a a matrix in a list.
#'
#' @seealso
#' * This function is used in: [simplify_idaifield()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' test_2 <- list(type = "Polygon",
#'     coordinates = list(list(list(1), list(1)),
#'                        list(list(1), list(2)),
#'                        list(list(2), list(2)),
#'                        list(list(1), list(1))
#'                        )
#' )
#'
#' reformat_geometry(test_2)
#'
#' }
reformat_geometry <- function(geometry) {
  # get the type of the geometry
  type <- geometry$type

  # if the type is not NULL
  if (!is.null(type)) {
    # if the type is a point
    if (type == "Point") {
      # get the coordinates of the point
      p_coords <- unlist(geometry$coordinates)
      # if the length of the coordinates is even
      if (length(p_coords) %% 2 == 0) {
        # convert the coordinates to a matrix with 2 columns
        geometry$coordinates <- list(matrix(p_coords,
                                            ncol = 2))
        # add a third column with 0
        geometry$coordinates[[1]] <- cbind(geometry$coordinates[[1]], 0)
      } else {
        # if it is not even (i.e. there already is a z-dim)
        # convert the coordinates to a matrix with 3 columns
        geometry$coordinates <- list(matrix(p_coords,
                                            ncol = 3))
      }
      # if the type is a polygon, line string or multi point
    } else if (type %in% c("Polygon", "LineString", "MultiPoint")) {
      # convert the coordinates to a matrix
      geometry$coordinates <- list(convert_to_coordmat(geometry$coordinates))

      # if the type is a multi polygon or multi line string
    } else if (type %in% c("MultiPolygon", "MultiLineString")) {
      # convert each list of coordinates to a matrix
      geometry$coordinates <- lapply(geometry$coordinates,
                                     function(x) convert_to_coordmat(x))
    }
  }
  return(geometry)
}
