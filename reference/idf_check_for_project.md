# Check for the Existence of a Project in a Field Database (internal)

This function checks if a given project exists in the Field Database. If
the project does not exist, it throws an error.

## Usage

``` r
idf_check_for_project(conn, project = NULL)
```

## Arguments

- conn:

  The connection settings as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- project:

  character. Name of the project-database to check for. If not supplied,
  the function will use the project specified in the connection
  settings.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
check_for_project(conn) # Will not return anything
} # }
```
