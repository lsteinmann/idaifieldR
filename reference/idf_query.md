# Query *docs* from an iDAI.field Database Directly

This function can be used to gather *docs* from an iDAI.field / Field
Desktop Database according to the values of specific fields.

## Usage

``` r
idf_query(
  connection,
  field = "category",
  value = "Pottery",
  projectname = NULL
)
```

## Arguments

- connection:

  A connection settings object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- field:

  character. The resource field that should be selected for (i.e.
  "category" for the category of resource (*Pottery*, *Brick*,
  *Layer*)).

- value:

  character. The value to be selected for in the specified field (i.e.
  "*Brick*" when looking for resources of category *Brick*).

- projectname:

  (deprecated) The name of the project to be queried (overrides the one
  listed in the connection-object).

## Value

An `idaifield_docs` list containing all *docs* that fit the query
parameters.

## See also

- Alternative functions:
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
idf_query(conn, field = "category", value = "Brick")
} # }
```
