# Convert a List to a JSON-String

You can use `sf::st_read(geojson_string, quiet = TRUE)` to convert this
to a geometry you can plot in R.

## Usage

``` r
maybe_to_json(x)
```

## Arguments

- x:

  A list that should be converted (back) to a JSON string.

## Value

A JSON-string

## See also

- This function is used in:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)
