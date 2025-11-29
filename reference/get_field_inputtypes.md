# Produce a Matrix of Field *inputTypes* from the Custom Project Configuration

This function retrieves a matrix containing the *inputTypes* of all
custom fields from a project configuration of an
[iDAI.field](https://github.com/dainst/idai-field) project.

## Usage

``` r
get_field_inputtypes(
  config,
  inputType = "all",
  remove_config_names = TRUE,
  silent = FALSE
)
```

## Arguments

- config:

  A configuration list as returned by
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md)

- inputType:

  If specified, matrix is filtered to return only the specified type.

- remove_config_names:

  TRUE/FALSE: Should the name of the project be removed from field names
  of the configuration? (Default is TRUE.) (Should e.g.: *test:amount*
  be renamed to *amount*, see
  [`remove_config_names()`](https://lsteinmann.github.io/idaifieldR/reference/remove_config_names.md).)

- silent:

  TRUE/FALSE, default: FALSE. Should messages be suppressed?

## Value

A matrix of fields (with the given *inputType*).

## See also

- [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md),
  [`convert_to_onehot()`](https://lsteinmann.github.io/idaifieldR/reference/convert_to_onehot.md)

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(serverip = "127.0.0.1",
                          pwd = "hallo",
                          project = "rtest")
config <- get_configuration(connection = conn)
checkboxes <- get_field_inputtypes(config, inputType = "checkboxes")
} # }
```
