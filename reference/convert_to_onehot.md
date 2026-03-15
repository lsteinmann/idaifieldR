# Break down a List from a Checkbox Field to Onehot-Coded Values

This function converts all checkboxes fields (except the ones listed in
the `except`-param) into "one-hot" coded list items.

## Usage

``` r
convert_to_onehot(resource, inputtypes, except = NULL)
```

## Arguments

- resource:

  The resource to process (from an `idaifield_resources`-list).

- inputtypes:

  A matrix of fields with the given inputType as returned by
  [`parse_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/parse_field_inputtypes.md)

- except:

  A vector of fieldnames that should be ignored.

## Value

The resource object with the values of checkboxes separated into
one-hot-coded versions.

## See also

- Needs output of:
  [`parse_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/parse_field_inputtypes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
...
} # }
```
