# Convert an `idaifield_simple`-list to a Matrix

Converts a list of class `idaifield_docs`, `idaifield_resource` or
`idaifield_simple` into a matrix. Recommended to use with
`idaifield_simple`-lists as returned by
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).
If given a list of class `idaifield_docs` containing all meta-info, it
will automatically unnest to resource level. It is recommended to select
the list first using
[`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md)
from this package to reduce the amount of columns returned. See example.

## Usage

``` r
idaifield_as_matrix(idaifield)
```

## Arguments

- idaifield:

  An object as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
  [`check_and_unnest()`](https://lsteinmann.github.io/idaifieldR/reference/check_and_unnest.md)
  or
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Value

a matrix (depending on selection and project database it can be very
large)

## See also

- [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R",
                                pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = connection,
                                     projectname = "rtest")
pottery <- select_by(idaifield_docs, by = "category", value = "Pottery")
pottery <- simplify_idaifield(pottery,
                              uidlist = get_uid_list(idaifield_docs))
pottery <- idaifield_as_matrix(pottery)
} # }
```
