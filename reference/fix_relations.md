# Unnest the Relations in a Resource and Replace the UUIDs with *identifiers*

The function will flatten the relations list to more non-nested lists
with with *relation.*-prefix and replace the UUIDs in the lists values
with the corresponding *identifier*s from the uidlist/index (see
[`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
or
[`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md))
using
[`replace_uid()`](https://lsteinmann.github.io/idaifieldR/reference/replace_uid.md)
to make the result more readable.

## Usage

``` r
fix_relations(resource, replace_uids = TRUE, uidlist = NULL)
```

## Arguments

- resource:

  One element from a list of class `idaifield_resources`.

- replace_uids:

  TRUE/FALSE. If TRUE, replaces the UUIDs in each relation with the
  corresponding identifiers. If FALSE, just flattens the list. Default
  is TRUE.

- uidlist:

  Only needs to be provided if `replace_uids = TRUE`. A data.frame as
  returned by
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)
  or
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).

## Value

The same resource with its relations unnested (and replaced with
*identifier*s if `replace_uids` is set to `TRUE`).

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Examples

``` r
if (FALSE) { # \dontrun{
index <- data.frame(
  identifier = c("name1", "name2"),
  UID = c("15754929-dd98-acfa-bfc2-016b4d5582fe",
          "bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
 )
resource <- list(relations = list(
    isRecordedIn = list("15754929-dd98-acfa-bfc2-016b4d5582fe"),
    liesWithin = list("bf06c7b0-dba0-dcfa-6d8e-3b3509fee5b6")
  ),
  identifier = "res_1"
)

new_relations_list <- fix_relations(resource, replace_uids = TRUE, uidlist = index)
new_relations_list

new_relations_list <- fix_relations(resource, replace_uids = FALSE)
new_relations_list
} # }
```
