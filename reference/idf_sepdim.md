# Convert a List of Dimensions to Simpler Values

This function breaks down a list of dimensions (e.g. `dimensionLength`,
`dimensionWidth`, etc.) from a single resource (element) of an
`idaifield_docs` or `idaifield_resources` object and converts them to
simple values.It is used as a helper function for
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Usage

``` r
idf_sepdim(dimensionList, name = NULL)
```

## Arguments

- dimensionList:

  A list of dimensions (e.g. `dimensionLength`, `dimensionWidth`, etc.)
  from a single resource (element) of an `idaifield_docs` or
  `idaifield_resources` object.

- name:

  character. The name of the corresponding dimension list. Defaults to
  "dimension".

## Value

A list containing simple values for each measured dimension from the
list. If a range was entered, the function returns the mean without
further comment.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
dimensionLength_new <- idf_sepdim(idaifield_resources[[1]]$dimensionLength, "dimensionLength")
} # }
```
