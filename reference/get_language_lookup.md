# Prepare a Language List as a Lookup Table

The function compiles a table of background values and their
translations in the language selected from the configuration supplied to
it. Current Configuration resources from the database obtained by
[`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md)
only contain canges made after the addition of the project configuration
editor in iDAI.field 3. You can obtain older language configurations
with
[`download_language_list()`](https://lsteinmann.github.io/idaifieldR/reference/download_language_list.md)
from the iDAI.field GitHub repository.

## Usage

``` r
get_language_lookup(lang_list, language = "en", remove_config_names = TRUE)
```

## Arguments

- lang_list:

  A list in the format used by iDAI.fields configuration, containing a
  separate list for each language with its short name (e.g. "en", "de")
  in which the "commons", "categories" etc. lists are contained. Can be
  obtained with
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md).

- language:

  Language short name that is to be extracted, e.g. "en", defaults to
  "en"

- remove_config_names:

  TRUE/FALSE: Should the name of the project be removed from field names
  of the configuration? (Default is TRUE.) (Should e.g.: *test:amount*
  be renamed to *amount*, see
  [`remove_config_names()`](https://lsteinmann.github.io/idaifieldR/reference/remove_config_names.md).)

## Value

A data.frame that can serve as a lookup table, with the background name
in the "var" column, and the selected language in the "label" column.

## Details

Be aware: if two things have the same name in the background of the
database / project configuration but you use different translations this
will result in only one of the translations being used.

## See also

- Get the necessary configuration:
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md)
  or the default configurations available online:
  [`download_language_list()`](https://lsteinmann.github.io/idaifieldR/reference/download_language_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(serverip = "127.0.0.1",
                          project = "rtest",
                          pwd = "hallo")
config <- get_configuration(connection = conn)
lookup <- get_language_lookup(config$languages, language = "en")
} # }
```
