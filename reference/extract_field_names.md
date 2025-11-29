# Create a data.frame from a list of labels and descriptions from iDAI.field

Helper to
[`get_language_lookup()`](https://lsteinmann.github.io/idaifieldR/reference/get_language_lookup.md)

## Usage

``` r
extract_field_names(fields_list)
```

## Arguments

- fields_list:

  A named list that contains one or two other named lists ("label" and
  "description") with the translation / display language of the
  respective internal value (i.e. the name of the list)

- language:

## Value

a data frame with the column "var" and "label" containing the value in
var and its respective translation / display value in "label"

## Examples

``` r
if (FALSE) { # \dontrun{
fields_list <- list("category" = list("label" = "Category"),
                    "identifier" = list("label" = "Name / ID (unique)",
                    "description" = "Description of the field"))
df <- extract_field_names(fields_list)
} # }
```
