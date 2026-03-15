# Handle a `dropdownRange` Input Field from an iDAI.field Resource

Flattens a single `dropdownRange`-type field value from an iDAI.field
resource into a named list with two elements: `<name>.start` and
`<name>.end`. If only the start value exists, both `<name>.start` and
`<name>.end` are set to the start value.

## Usage

``` r
handle_dropdownrange_input(dropdownRangeInput, name)
```

## Arguments

- dropdownRangeInput:

  The value of a single `dropdownRange`-type field from a resource, i.e.
  `period` from the default Configuration. Expects a list with at
  minimum a `value` element and optionally an `endValue`.

- name:

  Character. The name of the field being processed (e.g. `"period"`).
  Used to name the output elements as `<name>.start` and `<name>.end`.

## Value

A named list with two elements:

- .start:

  The start value as a character string.

- .end:

  The end value as a character string, or the start value if no endValue
  was found.

Unexpected input formats return `NA` for both values.

## See also

- [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)
  which dispatches to this function.

## Examples

``` r
if (FALSE) { # \dontrun{
handle_dropdownrange_input(list(value = "Classical"), "period")

# Current format, date range with time
handle_date_input(
  list(value = "Classical", endValue = "Hellenistic"),
  "period"
)
} # }
```
