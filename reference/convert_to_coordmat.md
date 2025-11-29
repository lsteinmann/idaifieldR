# Converts Coordinate List from iDAI.field to a Matrix

Converts Coordinate List from iDAI.field to a Matrix

## Usage

``` r
convert_to_coordmat(coordinates)
```

## Arguments

- coordinates:

  a list of the format that any coordinates list has in the iDAI.field 2
  / Field Desktop database.

## Value

a matrix that displays the same coordinates.

## Examples

``` r
if (FALSE) { # \dontrun{
test_2 <- list(type = "Polygon", coordinates = list(list(list(1), list(1)),
list(list(1), list(2)),
list(list(2), list(2)),
list(list(1), list(1))))

convert_polygon(test_2$coordinates)
} # }
```
