# Show the *categories* Present in an `idaifield_docs`- or `idaifield_resources`-list

Returns a list of all *categories* present in the iDAI.field 2 / Field
Desktop database the list was imported from.

## Usage

``` r
idf_show_categories(idaifield_docs)
```

## Arguments

- idaifield_docs:

  An an `idaifield_docs`- or `idaifield_resources`-list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)
  or
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md)
  and
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

## Value

A character vector with the unique categories present in the iDAI.field
2 / Field Desktop database the list was imported from.

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R",
                                pwd = "hallo",
                                project = "rtest")

idaifield_docs <- get_idaifield_docs(connection = connection)

idf_show_categories(idaifield_docs)
} # }
```
