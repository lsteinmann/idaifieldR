# Finding the "resource"-list in a CouchDB-output

Finding the "resource"-list in a CouchDB-output

## Usage

``` r
find_resource(list)
```

## Arguments

- list:

  a list formatted from a CouchDB-JSON-output

## Value

the list of resource-lists

## Examples

``` r
if (FALSE) { # \dontrun{
testlist <- list(docs = list(list(resource = list(test = "test",
                                                  test2 = "test2")),
                             list(resource = list(test = "test",
                                                  test2 = "test2"))),
                 warning = "warning")
find_resource(testlist)
} # }
```
