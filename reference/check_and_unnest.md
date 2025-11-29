# Check and Unnest an `idaifield_docs`-list

Checks if the input object is an `idaifield_docs`-list, and if it is
already unnested (i.e., of class `idaifield_resources` or
`idaifield_simple`). If the object is not unnested, the function unnests
it by stripping all top-level lists and returning only the list called
"resource" within the db docs. If the input object cannot be processed
because it is not an `idaifield_docs` or an unnested
`idaifield_resources` or `idaifield_simple` object, the function issues
a warning and returns the same object. You may force the function to
process it anyway using `force = TRUE`, but the outcome is uncertain.

## Usage

``` r
check_and_unnest(idaifield_docs, force = FALSE)
```

## Arguments

- idaifield_docs:

  An object of class `idaifield_docs` to be processed.

- force:

  TRUE/FALSE. Should the function attempt to unnest the input object
  regardless of type or class? Default is FALSE.

## Value

If already unnested, the same object as handed to it. If not, the same
list with the top-level lists removed down to the "resource"-level.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
idaifield_docs <- get_idaifield_docs(conn, raw = TRUE)

# Check if idaifield_docs is already unnested, and if not, do so:
idaifield_docs <- check_and_unnest(idaifield_docs)
} # }
```
