# Simplify a Single Resource from an iDAI.field / Field Desktop Database

Helper function to
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).
Transforms a single resource from an `idaifield_resources` list into a
flatter, more R-friendly structure.

## Usage

``` r
simplify_single_resource(
  resource,
  index = NULL,
  inputtypes = NULL,
  replace_uids = TRUE,
  keep_geometry = TRUE,
  silent = FALSE
)
```

## Arguments

- resource:

  One element from an `idaifield_resources` list.

- index:

  A data.frame as returned by
  [`make_index()`](https://lsteinmann.github.io/idaifieldR/reference/make_index.md)
  or
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).
  Required for UUID replacement and layer detection.

- replace_uids:

  logical. Should UUIDs in relations be replaced with human-readable
  identifiers from `index`? Default is TRUE.

- keep_geometry:

  logical. Should geometry be kept as a GeoJSON string? Default is TRUE.

- silent:

  logical. Should messages be suppressed? Default is FALSE.

## Value

A single resource with relations flattened, geometry handled, and simple
fields unlisted to vectors.

## See also

[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md),
[`fix_relations()`](https://lsteinmann.github.io/idaifieldR/reference/fix_relations.md),
[`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
index <- make_index(docs)
config <- get_configuration(conn)
simpler <- simplify_single_resource(docs[[1]],
  index = index,
  config = config,
  keep_geometry = FALSE
)
} # }
```
