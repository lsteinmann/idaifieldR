# Unnesting a `idaifield_docs`-List down to resource level

This function unnests the lists provided by iDAI.field / Field Desktop.
The actual data of a resource is usually stored in a sub-list behind
\$doc\$resource, which contains the data one would mostly want to work
with in R. The top level data contains information about who created and
modified the resource at what time and is irrelevant for any analysis of
the database contents itself.

## Usage

``` r
unnest_docs(docs)
```

## Arguments

- docs:

  A list as provided by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md).
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)
  employs this function already when setting `raw = FALSE`.

## Value

a list of class `idaifield_resources` (same as `idaifield_docs`, but the
top-level with meta-information has been removed to make the actual
resource data more accessible)

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(
  serverip = "localhost",
  project = "rtest",
  pwd = "hallo"
)
idaifield_docs <- get_idaifield_docs(connection = connection)

idaifield_resources <- unnest_docs(idaifield_docs)
} # }
```
