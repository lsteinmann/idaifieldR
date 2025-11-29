# Query *docs* from an iDAI.field Database Based on a JSON-Query

This function can be used to gather *docs* from an iDAI.field / Field
Desktop Database using a JSON-Query as detailed by the [CouchDB-API
Docs](https://docs.couchdb.org/en/stable/api/database/find.html).

## Usage

``` r
idf_json_query(connection, query, projectname = NULL)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- query:

  A valid JSON-query as detailed in the relevant section of the
  [CouchDB-API](https://docs.couchdb.org/en/stable/api/database/find.html)
  documentation.

- projectname:

  (deprecated) The name of the project to be queried (overrides the one
  listed in the connection-object).

## Value

An `idaifield_docs` list

## See also

- Learn how to build the selector-query with the
  [CouchDB-API](https://docs.couchdb.org/en/stable/api/database/find.html).

- Alternative functions:
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")

# Get all documents that contain "Anna Allgemeinperson" as processor
query <- '{ "selector": { "resource.processor": ["Anna Allgemeinperson"] } }'
result <- idf_json_query(conn, query = query)


# Get all documents where hasRestoration is TRUE
query <- '{ "selector": { "resource.hasRestoration": true } }'
result <- idf_json_query(conn, query = query)

# Get all documents where hasRestoration is TRUE
# but only the fields *identifier* and *hasRestoration*
query <- '{ "selector": { "resource.hasRestoration": true },
"fields": [ "resource.identifier", "resource.hasRestoration" ] }'
result <- idf_json_query(conn, query = query)

} # }
```
