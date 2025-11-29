# Create a Connection Client to a Field database (internal)

This function creates a
[crul::HttpClient](https://docs.ropensci.org/crul/reference/HttpClient.html)object
for use in retrieving all documents from or querying a Field database
associated with a specific project. This function is intended for
internal use only.

## Usage

``` r
proj_idf_client(conn, project = NULL, include = "all")
```

## Arguments

- conn:

  A connection object returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md).

- project:

  (deprecated) character. Name of the project-database that should be
  loaded.

- include:

  Arguments: "all", "query", "changes" . Should the client use
  "*\_all_docs*", "*\_find*" or "*\_changes*" as paths.

  - [crul on CRAN](https://cran.r-project.org/package=crul)

  - [CouchDB API](https://docs.couchdb.org/en/stable/api/database/)

## Value

A
[`crul::HttpClient()`](https://docs.ropensci.org/crul/reference/HttpClient.html)
object.

## See also

[`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)
for information about connecting to Field and
[`crul::HttpClient()`](https://docs.ropensci.org/crul/reference/HttpClient.html)
which this function uses.

## Examples

``` r
if (FALSE) { # \dontrun{
  connection <- connect_idaifield(pwd = "hallo", project = "rtest")
  client <- proj_idf_client(conn = connection)
} # }
```
