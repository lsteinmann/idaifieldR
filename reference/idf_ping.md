# Ping the Field-Database

This function checks if a connection to the Field Database can be
established. It returns a boolean value indicating if the connection was
successful or not. Warnings are used to indicate why the connection
failed, if so.

## Usage

``` r
idf_ping(conn)
```

## Arguments

- conn:

  An object that contains the connection settings, as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md).

## Value

A boolean value indicating if the connection was successful (TRUE) or
not (FALSE).

## See also

- Produce a Connection-Settings list with:
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- Find all projects in the database with:
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Establish a connection to the Field Database
conn <- connect_idaifield(ping = FALSE)

# Ping the Field Database
idf_ping(conn)
} # }
```
