# Break down a List from a Checkbox Field to Onehot-Coded Values

This function is a helper function to
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)
that takes a list from one of the fields marked in the config as
containing checkboxes and converts the list to onehot-coded values.

## Usage

``` r
convert_to_onehot(resource, fieldtypes)
```

## Arguments

- resource:

  The resource to process (from an `idaifield_resources`-list).

- fieldtypes:

  A matrix of fields with the given inputType as returned by
  [`get_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_inputtypes.md)

## Value

The resource object with the values of checkboxes separated into
one-hot-coded versions.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

- Needs output of:
  [`get_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_inputtypes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
...
} # }
```
