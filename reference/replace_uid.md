# Replace a Vector of UUIDs with their *identifier*s

When handed an item (a vector or a single variable) first checks if it
is actually a UUID as defined in check_if_uid() and if so, replaces it
with the corresponding *identifier* from the uidlist (also handed to the
function).

## Usage

``` r
replace_uid(uidvector, uidlist)
```

## Arguments

- uidvector:

  a vector of UUIDs to be replaced with their *identifier*s

- uidlist:

  a uidlist resp. index of as returned by
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)
  and
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)

## Value

The corresponding *identifier*(s) (a character string/vector)

## See also

- This function is used in:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md),
  [`fix_relations()`](https://lsteinmann.github.io/idaifieldR/reference/fix_relations.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
index <- get_field_index(conn)

replace_uid("02932bc4-22ce-3080-a205-e050b489c0c2", uidlist = index[, c("identifier", "UID")])
} # }
```
