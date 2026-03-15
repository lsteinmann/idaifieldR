# Update Legacy Two-Field Date Format in an iDAI.field Resource

Some older iDAI.field resources store date ranges as two separate
top-level fields — `beginningDate` and `endDate` — rather than a single
`date` list. Resources in Field Desktop are only updated to the new
format when they are actively worked on and saved. This function detects
those fields and brings them into the expected, current format, removing
the originals.

## Usage

``` r
handle_legacy_date_range_fields(resource)
```

## Arguments

- resource:

  A single resource (one element from an `idaifield_resources` list).

## Value

The resource with `beginningDate` and `endDate` removed and replaced by
a `date`-list to be handled by
[`handle_date_input()`](https://lsteinmann.github.io/idaifieldR/reference/handle_date_input.md).
Returned unchanged if neither field is present.

## Details

Resources without both `beginningDate` and `endDate` are returned
unchanged. If only one of the two fields is present, the other is set to
`NA`.

## See also

- [`handle_date_input()`](https://lsteinmann.github.io/idaifieldR/reference/handle_date_input.md)
  for the current and legacy single-field formats.

- [`simplify_single_resource()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_single_resource.md)
  which calls this as a pre-processing step.

## Examples

``` r
if (FALSE) { # \dontrun{
resource <- list(
  identifier    = "legacyResource",
  category      = "Feature",
  beginningDate = "12.03.2026",
  endDate       = "13.03.2026"
)
handle_legacy_date_fields(resource)
} # }
```
