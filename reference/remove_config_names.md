# Remove Everything Before the Colon in a Character Vector

Removes everything before the first colon (including the colon) in a
character vector. Used for cleaning up category or field names that have
been produced using the *Project Configuration Editor* in Field Desktop.

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

## Examples

``` r
if (FALSE) { # \dontrun{
nameslist <- c(
  "relation.liesWithin",
  "relation.liesWithinLayer",
  "campaign.2022",
  "rtest:test",
  "pergamon:neuesFeld",
  "neuesFeld"
)
remove_config_names(nameslist, silent = FALSE)
} # }
```
