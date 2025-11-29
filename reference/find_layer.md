# Find the Layer a Resource is Contained in

Helper to
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).
Traces the liesWithin fields to find the one that is a Layer and returns
the corresponding identifier.

## Usage

``` r
find_layer(
  ids,
  uidlist = NULL,
  layer_categories = NULL,
  max_depth = 20,
  silent = FALSE,
  id = NULL,
  id_type = NULL
)
```

## Arguments

- ids:

  Either the UUIDs or the identifiers resources from an
  `idaifield_...`-list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md)
  or
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

- uidlist:

  A data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  or
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md).

- layer_categories:

  A vector of *categories* that are classified as *Layer*s. (Encompasses
  *SurveyUnit*.) See or change the default:
  `getOption("idaifield_categories")$layers`

- max_depth:

  numeric. Maximum number of recursive iterations / maximum depth a
  resource may be nested below its layer.

- silent:

  TRUE/FALSE, default: FALSE. Should messages be suppressed?

- id:

  DEPRECATED. Either the UUID or the identifier of a resource from an
  `idaifield_...`-list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md)
  or
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

- id_type:

  DEPRECATED.

## Value

The identifier or UUID of the first "Layer"-category resource the given
id/identifier lies within.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md),
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md),
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
index <- get_field_index(conn)

 # For a nested Find:
index[which(index$identifier == "Befund_1_InschriftAufMünze"), ]
find_layer("Befund_1_InschriftAufMünze", index)

# For all resources:
find_layer(index$identifier, index)
} # }
```
