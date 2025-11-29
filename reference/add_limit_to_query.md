# Add limit to JSON query

This function adds a limit of the max db docs to a query.

## Usage

``` r
add_limit_to_query(query, conn)
```

## Arguments

- query:

  A MongoDB JSON-query as used in this package.

- conn:

  A connection object returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md).

## Value

A query with limit added for PouchDB

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(project = "test", pwd = "hallo")
fields <- c("resource.category", "resource.identifier")
query <- paste0('{ "selector": { "$not": { "resource.id": "" } },
   "fields": [', paste0('"', fields, '"', collapse = ", "), '] }')
add_limit_to_query(query, conn)
} # }
```
