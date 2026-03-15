# (Maybe) Unnests an `idaifield_docs`-list

Checks if the input object is an `idaifield_docs`-list. If so, the
function unnests it by stripping all top-level lists and returning only
the list called "resource" within the db docs. Any other class will
simply be returned unchanged.

## Usage

``` r
maybe_unnest_docs(x)
```

## Arguments

- x:

  An object of class `idaifield_docs` to be processed. Will return
  objects of other classes unchanged.

## Value

If already unnested, the same object as handed to it. If not, the same
list with the top-level lists removed down to the "resource"-level, as
an `idaifield_resources`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
idaifield_docs <- get_idaifield_docs(conn, raw = TRUE)
idaifield_resources <- maybe_unnest_docs(idaifield_docs)
} # }
```
