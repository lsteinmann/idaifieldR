# Get a vector of UUIDs or identifiers of the last n changed resources

Retrieves the names/identifiers or UUIDs of the most recently changed
resources in the database. If an index as returned by
[`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
or
[`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)
is returned, the UUIDs are replaced by identifiers. If not, the UUIDs
are returned directly and can be used for querying e.g. with

## Usage

``` r
idf_last_changed(connection, index = NULL, n = 100)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- index:

  A data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  (or
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)).

- n:

  numeric. Maximum number of last changed resources to get.

## Value

A vector of `UUID`s or `identifier`s of the most recently changed `n`
resources.

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(pwd = "hallo", project = "rtest")
index <- get_field_index(connection)
last_changed <- idf_last_changed(
    connection = connection,
    index = index,
    n = 100
)
} # }
```
