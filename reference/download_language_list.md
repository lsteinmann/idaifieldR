# Download a Language-List from GitHub

This function downloads language lists from the
[iDAI.field-GitHub-repository](https://github.com/dainst/idai-field) and
can be used to supply additional lists to
[`get_language_lookup()`](https://lsteinmann.github.io/idaifieldR/reference/get_language_lookup.md).

## Usage

``` r
download_language_list(project = "core", language = "en")
```

## Arguments

- project:

  name of the project for which the language files should be downloaded;
  case sensitive! Has to match the name in the Language-file exactly. If
  default ("core") is used, the common language file from the core
  library will be downloaded.

- language:

  Language short name that is to be extracted, e.g. "en", defaults to
  "en"

## Value

A list that can be processed with
[`get_language_lookup()`](https://lsteinmann.github.io/idaifieldR/reference/get_language_lookup.md).

## Examples

``` r
if (FALSE) { # \dontrun{
lang_list <- download_language_list(language = "de")
get_language_lookup(lang_list)
} # }
```
