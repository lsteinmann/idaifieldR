# Get the Custom Project Configuration as Provided by the Field Desktop API

This function retrieves the complete project configuration (if existent)
from an [iDAI.field](https://github.com/dainst/idai-field) project via
Field Desktop's configuration endpoint. The list will contain the
complete configuration as used in the project, including custom
*fields*, *valuelists* and *translations*.

## Usage

``` r
get_configuration(connection)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

## Value

A list of class `idaifield_config` containing the project configuration,
with `connection` and `projectname` stored as attributes. Returns `NA`
with a warning if the configuration could not be found or the connection
failed.

## See also

- Get the inputTypes from a Configuration:
  [`parse_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/parse_field_inputtypes.md)

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

- [iDAI.field Manual: 12. API](https://field.idai.world/manual)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(
  serverip = "localhost", pwd = "hallo", project = "rtest"
)
config <- get_configuration(connection = conn)
} # }
```
