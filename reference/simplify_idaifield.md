# Simplify a List Imported from an iDAI.field / Field Desktop Database

Takes a list as returned by
[`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
[`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
[`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
or
[`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md)
and transforms it into a flatter, more R-friendly structure.

## Usage

``` r
simplify_idaifield(
  resources,
  index = NULL,
  config = NULL,
  keep_geometry = FALSE,
  find_layers = FALSE,
  silent = FALSE,
  ...
)
```

## Arguments

- resources:

  An `idaifield_docs` or `idaifield_resources` list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
  or
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

- index:

  A data.frame as returned by
  [`make_index()`](https://lsteinmann.github.io/idaifieldR/reference/make_index.md)
  or
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).
  Required for UUID replacement and layer detection.

- config:

  An `idaifield_config` object as returned by
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md).
  Required when `find_layers = TRUE`.

- keep_geometry:

  logical. Should geometry be kept as a GeoJSON string? Default is TRUE.

- find_layers:

  logical. Should the containing layer be detected and added as
  `relation.liesWithinLayer`? Default is TRUE.

- silent:

  logical. Should messages be suppressed? Default is FALSE.

- ...:

  sink for deprecated params

## Value

An `idaifield_simple` list with the same resources in a flatter format,
with `connection`, `projectname` stored as attributes.

## Details

Relations are flattened into named vectors with a `relation.`-prefix
(e.g. `relation.liesWithin`). UUIDs in relations are replaced with
human-readable identifiers. Geometry is kept as a GeoJSON string if
`keep_geometry = TRUE`.

Note: If you are working with a subset of resources (e.g. from
[`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md)),
you should supply the `index` of the *complete* project database, not
just the subset — otherwise UUID replacement will be incomplete.

## See also

- [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)
  to import resources from the database

- [`make_index()`](https://lsteinmann.github.io/idaifieldR/reference/make_index.md)
  and
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  for building an index

- [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md)
  for the project configuration

- [`fix_relations()`](https://lsteinmann.github.io/idaifieldR/reference/fix_relations.md)
  for relation flattening

- [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md)
  for layer detection

- [`idaifield_as_matrix()`](https://lsteinmann.github.io/idaifieldR/reference/idaifield_as_matrix.md)
  for converting the result to a matrix

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(serverip = "localhost", project = "rtest", pwd = "hallo")
docs <- get_idaifield_docs(connection = conn)
simple <- simplify_idaifield(docs)
} # }
```
