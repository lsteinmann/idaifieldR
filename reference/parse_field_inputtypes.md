# Get a Data Frame of Field *inputTypes* from the Project Configuration

Extracts the *inputTypes* of all fields defined in a project
configuration of an [iDAI.field](https://github.com/dainst/idai-field)
project and returns them as a data.frame. Both supercategory and
subcategory fields are included. Fields inherited from parent categories
without an explicit `inputType` will appear as `"NULL"` in the
`inputType` column. Subfields of composite fields are currently not
recorded here.

## Usage

``` r
parse_field_inputtypes(config = NULL)
```

## Arguments

- config:

  An `idaifield_config` object as returned by
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md).

## Value

A data.frame with four columns:

- category:

  The (sub)category the field belongs to.

- parent:

  The supercategory, or the category itself if it is a supercategory.

- fieldname:

  The internal field name.

- inputType:

  The inputType string (e.g. `"text"`, `"checkboxes"`, `"dimension"`).

## See also

- [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md)
  to retrieve the configuration object.

- [`extract_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/extract_inputtypes.md)
  for the underlying extraction logic.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo",
                          project = "rtest")
config <- get_configuration(connection = conn)
input_type_df <- parse_field_inputtypes(config = config)
} # }
```
