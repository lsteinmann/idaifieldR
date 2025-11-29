# Reorders the column names for idaifield_as_matrix()

Reorders the column names for idaifield_as_matrix()

## Usage

``` r
reorder_colnames(colnames, order = "default")
```

## Arguments

- colnames:

  a character vector with colnames

- order:

  either "default" for default order (first columns are "identifier",
  "category", "shortDescription" and the rest is as assembled) or a
  character vector with exact column names that will then place these as
  the first n columns of the matrix produced by idaifield_as_matrix()

## Value

a character vector

## Examples

``` r
if (FALSE) { # \dontrun{
colnames <- c("materialType", "identifier", "shortDescription", "category")

reorder_colnames(colnames, order = "default")
} # }
```
