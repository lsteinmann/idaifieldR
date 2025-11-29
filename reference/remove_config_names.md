# Remove Everything Before the Colon in a Character Vector

This function removes everything before the first colon (including the
colon) in a character vector. It is used as a helper function for
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Usage

``` r
remove_config_names(
  conf_names = c("identifier", "configname:test", "test"),
  silent = FALSE
)
```

## Arguments

- conf_names:

  A character vector.

- silent:

  Should the message that duplicates were detected be suppressed?
  Default is FALSE.

## Value

The same character vector with everything before the first colon
(including the colon) removed.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md),
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  and
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
nameslist <- c("relation.liesWithin", "relation.liesWithinLayer",
"campaign.2022", "rtest:test", "pergamon:neuesFeld")
remove_config_names(nameslist, silent = FALSE)
} # }
```
