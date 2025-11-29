# Get a Vector of Project Names Present in the Database

Get a Vector of Project Names Present in the Database

## Usage

``` r
idf_projects(connection)
```

## Arguments

- connection:

  The connection settings as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

## Value

A character vector containing the projects present in the database, NA
if connection was refused.

## See also

- [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md),
  [`idf_ping()`](https://lsteinmann.github.io/idaifieldR/reference/idf_ping.md)

## Examples

``` r
if (FALSE) { # \dontrun{
 connection <- connect_idaifield(pwd = "hallo")
 idf_project_list(connection)
} # }
```
