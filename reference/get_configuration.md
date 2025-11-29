# Get the Custom Project Configuration as Stored in the Project Database

This function retrieves the project configuration (if existent) from an
[iDAI.field](https://github.com/dainst/idai-field) project. The list
will only contain fields and valuelists that have been edited in the
project configuration editor in iDAI.field 3 (Field Desktop) and does
not encompass *fields*, *valuelists* and *translation* added before the
update to [iDAI.field](https://github.com/dainst/idai-field) 3.

## Usage

``` r
get_configuration(connection, projectname = NULL)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- projectname:

  (deprecated) The name of the project in the Field Client that one
  wishes to load. Will overwrite the project argument that was set in
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md).

## Value

A list containing the project configuration; `NA` if the configuration
could not be found or the connection failed.

## See also

- Get the inputTypes from a Configuration:
  [`get_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_inputtypes.md)

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(serverip = "127.0.0.1",
user = "R", pwd = "hallo", project = "rtest")
config <- get_configuration(connection = conn,
projectname = "rtest")
} # }
```
