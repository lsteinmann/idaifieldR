# Flatten Relations and Optionally Replace UUIDs

Flattens the nested `relations` list of a resource into individual named
vectors with a `relation.`-prefix (e.g. `relation.isAbove`), and
optionally replaces UUIDs with human-readable identifiers from the
index.

## Usage

``` r
fix_relations(resource, replace_uids = TRUE, index = NULL, uidlist = NULL)
```

## Arguments

- resource:

  One element from an `idaifield_resources` list.

- replace_uids:

  logical. Should UUIDs be replaced with identifiers from `index`?
  Default is TRUE.

- index:

  A data.frame as returned by
  [`make_index()`](https://lsteinmann.github.io/idaifieldR/reference/make_index.md)
  or
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).
  Required if `replace_uids = TRUE`.

- uidlist:

  DEPRECATED

## Value

The resource with its `relations` list removed and replaced by flat
named vectors, one per relation type.

## See also

[`replace_uid()`](https://lsteinmann.github.io/idaifieldR/reference/replace_uid.md),
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
index <- data.frame(
  identifier = c("name1", "name2"),
  UID = c("15754929-dd98-acfa-bfc2-016b4d5582fe",
          "bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
)
resource <- list(
  identifier = "res_1",
  relations = list(
    isRecordedIn = list("15754929-dd98-acfa-bfc2-016b4d5582fe"),
    liesWithin = list("bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
  )
)
fix_relations(resource, replace_uids = TRUE, index = index)
fix_relations(resource, replace_uids = FALSE)
} # }
```
