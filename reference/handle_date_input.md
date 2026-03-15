# Handle a `date` Input Field from an iDAI.field Resource

Flattens a single `date`-type field value from an iDAI.field resource
into a named list with two elements: `<name>.start` and `<name>.end`.
Handles both the legacy format (a plain character string) and the
current format (a list with `value`, optional `endValue`, and
`isRange`).

## Usage

``` r
handle_date_input(dateInput, name)
```

## Arguments

- dateInput:

  The value of a single `date`-type field from a resource, i.e.
  `resource$date` or `resource$restorationDate`. Either a character
  string (legacy single-field format) or a list with at minimum a
  `value` element and an `isRange` logical (current format).

- name:

  Character. The name of the field being processed (e.g. `"date"`,
  `"restorationDate"`). Used to name the output elements as
  `<name>.start` and `<name>.end`.

## Value

A named list with two elements:

- .start:

  The start date as a character string.

- .end:

  The end date as a character string, or `NA` if the field is not a
  range.

## Details

Date strings are returned exactly as stored in the database — no
parsing, type conversion, or format normalisation is applied. Possible
formats include `"DD.MM.YYYY"`, `"DD.MM.YYYY HH:MM"`, `"MM.YYYY"`, and
`"YYYY"`.

For the legacy two-field format (`beginningDate` / `endDate` as separate
top-level keys in the resource), use
[`handle_legacy_date_range_fields()`](https://lsteinmann.github.io/idaifieldR/reference/handle_legacy_date_range_fields.md)
on the whole resource before per-field dispatch.

## See also

- [`handle_legacy_date_range_fields()`](https://lsteinmann.github.io/idaifieldR/reference/handle_legacy_date_range_fields.md)
  for the legacy two-field format.

- [`simplify_single_resource()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_single_resource.md)
  which dispatches to this function.

## Examples

``` r
if (FALSE) { # \dontrun{
# Current format, single date
handle_date_input(list(value = "12.03.2026", isRange = FALSE), "date")

# Current format, date range with time
handle_date_input(
  list(value = "19.08.2017 17:25", endValue = "20.08.2017 11:09", isRange = TRUE),
  "date"
)

# Legacy plain string
handle_date_input("12.03.2026", "date")

# Named after a custom date field
handle_date_input(list(value = "2025", isRange = FALSE), "restorationDate")
} # }
```
