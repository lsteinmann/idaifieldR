# Query *docs* from an iDAI.field Database Based on an Index (uidlist)

This function can be used to gather *docs* from an iDAI.field / Field
Desktop Database according to the values of listed in an index as
returned by
[`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
or
[`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md).

## Usage

``` r
idf_index_query(
  connection,
  field = "category",
  value = "Brick",
  uidlist = NULL,
  projectname = NULL
)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- field:

  character. The resource field that should be selected for (options are
  limited to the column names of the uidlist).

- value:

  character. The value to be selected for in the specified field.

- uidlist:

  A data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  (or
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)).

- projectname:

  (deprecated) The name of the project to be queried (overrides the one
  listed in the connection-object).

## Value

An `idaifield_docs` list

## See also

- Alternative functions:
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
uidlist <- get_field_index(conn)
idf_index_query(conn,
                field = "category",
                value = "Brick",
                uidlist = uidlist)
} # }
```
