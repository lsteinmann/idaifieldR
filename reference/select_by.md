# Deprecated function: Select/filter an `idaifield_resources`- or `idaifield_docs`-list

This function has been deprecated in favour of
[`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md).

## Usage

``` r
select_by(idaifield_docs, by = c("category", "isRecordedIn"), value = NULL)
```

## Arguments

- idaifield_docs:

  An `idaifield_resources`- or `idaifield_docs`-list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)
  etc.

- by:

  Any name of a field that might by present in the resource lists, e.g.
  category, identifier, processor etc.

- value:

  character. Should be the internal name of the value that will be
  selected for (e.g. "Layer", "Pottery"), can also be vector of multiple
  values.

## Value

A list of class `idaifield_resources` containing the resources which
contain the specified values.

## Details

Subset or filter the list of the docs or resources by the given
parameters. You may want to consider querying the database directly
using
[`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
[`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md)
and
[`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

## See also

[`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(serverip = "127.0.0.1",
user = "R", pwd = "hallo", project = "rtest")
idaifield_docs <- get_idaifield_docs(connection = connection)

idaifield_layers <- idf_select_by(idaifield_docs,
by = "category",
value = "Layer")

idaifield_anna <- idf_select_by(idaifield_docs,
by = "processor",
value = "Anna Allgemeinperson")
} # }
```
