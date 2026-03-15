# Get the Index of an `idaifield_docs`/`idaifield_resources`-list

All resources in the project databases in [iDAI.field / Field
Desktop](https://github.com/dainst/idai-field) are stored and referenced
with their Universally Unique Identifier (UUID) in the relations fields.
Therefore, for many purposes a lookup-table needs to be provided in
order to get to the actual identifiers of the resources referenced.
Single UUIDs or vectors of UUIDs can be replaced individually using
[`replace_uid()`](https://lsteinmann.github.io/idaifieldR/reference/replace_uid.md)
from this package.

This function is also good for a quick overview / a list of all the
resources that exist along with their identifiers and short descriptions
and can be used to select the resources along their respective
Categories (e.g. Pottery, Layer etc., formerly named "type"). Please
note that in any case the internal names of everything will be used. If
you relabeled `Trench` to `Schnitt` in your language-configuration, the
name will still be `Trench` here. None of these functions have any
respect for language settings of a project configuration, i.e. the front
end languages of valuelists and fields are not displayed, and instead
their background names are used. You can see these in the project
configuration settings.

## Usage

``` r
make_index(
  idaifield_docs,
  verbose = FALSE,
  gather_trenches = FALSE,
  language = "all",
  ...
)
```

## Arguments

- idaifield_docs:

  An object as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)

- verbose:

  TRUE or FALSE. Defaults to FALSE. TRUE returns a list including
  identifier and shortDescription which is more convenient to read, and
  FALSE returns only UUID, category (former: type) and basic relations,
  which is sufficient for internal use.

- gather_trenches:

  defaults to FALSE. If TRUE, adds another column that records the Place
  each corresponding Trench and its sub-resources lie within. (Useful
  for grouping the finds of several trenches, but will only work if the
  project database is organized accordingly.)

- language:

  The short name (e.g. "en", "de", "fr") of the language that is
  preferred for the fields. Special value "all" (the default) can be
  used to return a concatenated string of all available languages.
  [`gather_languages()`](https://lsteinmann.github.io/idaifieldR/reference/gather_languages.md)
  will select other available languages in alphabetical order if the
  selected language is not available.

- ...:

  sink for deprecated params

## Value

a data.frame with identifiers and corresponding UUIDs along with the
category (former: type), basic relations and depending on settings
place, shortDescription and "liesWithinLayer" of each element

## See also

- Superseded by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md),
  which queries the database directly.

- [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md)
  is used when `find_layers = TRUE` to search for the containing
  layer-resource recursively.

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(serverip = "localhost",
                                project = "rtest", pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = connection)

uidlist <- make_index(idaifield_docs, verbose = TRUE)
} # }
```
