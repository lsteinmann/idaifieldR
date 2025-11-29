# Check for `idaifield_...` classes

For internal use... checks if an object can actually processed by the
functions in this package which need the specific format that is
returned by the core function get_idaifield_docs(...).

## Usage

``` r
check_if_idaifield(testobject)
```

## Arguments

- testobject:

  An object that should be evaluated.

## Value

a matrix that allows other functions to determine which type of list the
object is

## Examples

``` r
if (FALSE) { # \dontrun{
idaifield_docs <- get_idaifield_docs(projectname = "rtest",
connection = connect_idaifield(serverip = "127.0.0.1",
user = "R",
pwd = "password"))

check_if_idaifield(idaifield_docs)
} # }
```
