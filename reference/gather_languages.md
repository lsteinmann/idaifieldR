# Gather Fields with Multiple Language Values

This function extracts the values for a preferred language from a list
containing values in multiple languages.

## Usage

``` r
gather_languages(input_list, language = "all", silent = FALSE)
```

## Arguments

- input_list:

  A list with character values containing (or not) sublists for each
  language.

- language:

  The short name (e.g. "en", "de", "fr") of the language that is
  preferred for the fields. Special value "all" (the default) can be
  used to return a concatenated string of all available languages.
  `gather_languages()` will select other available languages in
  alphabetical order if the selected language is not available.

- silent:

  TRUE/FALSE: Should gather_languages() issue messages and warnings?

## Value

A character vector containing the values in the preferred language.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
input_list <- list(list("en" = "English text", "de" = "Deutscher Text"),
                   list("en" = "Another english text", "de" = "Weiterer dt. Text"))
gather_languages(input_list, language = "de")
} # }
```
