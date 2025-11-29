# Reformat the Geometry of a single iDAI.field / Field Desktop resource

Reformat the Geometry of a single iDAI.field / Field Desktop resource

## Usage

``` r
reformat_geometry(geometry)
```

## Arguments

- geometry:

  The list in `resource$geometry` of an `idaifield_docs`- or
  `idaifield_resources`-list.

## Value

The geometry of the resource in a more usable format that can be
processed with tools like `sp`'s `SpatialPoints()` etc. to work with
spatial data. The geometry is returned as a a matrix in a list.

## See also

- This function is used in:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
test_2 <- list(type = "Polygon",
    coordinates = list(list(list(1), list(1)),
                       list(list(1), list(2)),
                       list(list(2), list(2)),
                       list(list(1), list(1))
                       )
)

reformat_geometry(test_2)

} # }
```
