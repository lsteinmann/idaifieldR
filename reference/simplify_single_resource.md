# Simplifies a single resource from the iDAI.field 2 / Field Desktop Database

This function is a helper to
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md).

## Usage

``` r
simplify_single_resource(
  resource,
  replace_uids = TRUE,
  find_layers = TRUE,
  uidlist = NULL,
  keep_geometry = TRUE,
  fieldtypes = NULL,
  remove_config_names = TRUE,
  language = "all",
  spread_fields = TRUE,
  use_exact_dates = FALSE,
  silent = FALSE
)
```

## Arguments

- resource:

  One resource (element) from an `idaifield_resources`-list.

- replace_uids:

  TRUE/FALSE: Should UUIDs be automatically replaced with the
  corresponding identifiers? Defaults is TRUE. Uses:
  [`fix_relations()`](https://lsteinmann.github.io/idaifieldR/reference/fix_relations.md)
  with
  [`replace_uid()`](https://lsteinmann.github.io/idaifieldR/reference/replace_uid.md),
  and also:
  [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md)

- find_layers:

  TRUE/FALSE. Default is FALSE. If TRUE, adds another column with the
  'Layer' (see `getOption("idaifield_categories")$layers`, can be
  modified) in which a resource is contained recursively. That means
  that even if it does not immediately lie within this layer, but is
  contained by one or several other resources in said layer, a new
  column ("liesWithinLayer") will still show the layer. Example: A
  sample "A" in Find "001" from layer "Layer1" will usually have "001"
  as the value in "liesWithin". With find_layers, there will be another
  column called "liesWithinLayer" which contains "Layer1" for both
  sample "A" and Find "001".

- uidlist:

  If NULL (default) the list of UUIDs and identifiers is automatically
  generated within this function using
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md).
  This only makes sense if the list handed to
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)
  had not been selected yet. If it has been, you should supply a
  data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).

- keep_geometry:

  TRUE/FALSE: Should the geographical information be kept or removed?
  Defaults is FALSE. Uses:
  [`reformat_geometry()`](https://lsteinmann.github.io/idaifieldR/reference/reformat_geometry.md)

- remove_config_names:

  TRUE/FALSE: Should the name of the project be removed from field names
  of the configuration? (Default is TRUE.) (Should e.g.: *test:amount*
  be renamed to *amount*, see
  [`remove_config_names()`](https://lsteinmann.github.io/idaifieldR/reference/remove_config_names.md).)

- language:

  The short name (e.g. "en", "de", "fr") of the language that is
  preferred for the fields. Special value "all" (the default) can be
  used to return a concatenated string of all available languages.
  [`gather_languages()`](https://lsteinmann.github.io/idaifieldR/reference/gather_languages.md)
  will select other available languages in alphabetical order if the
  selected language is not available.

- spread_fields:

  TRUE/FALSE: Should checkbox-fields be spread across multiple lists to
  facilitate boolean-columns for each value of a checkbox-field? Default
  is TRUE. Uses:
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md),
  [`get_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_inputtypes.md),
  [`convert_to_onehot()`](https://lsteinmann.github.io/idaifieldR/reference/convert_to_onehot.md)

- use_exact_dates:

  TRUE/FALSE: Should the values from any "exact" dates be used in case
  there are any? Default is FALSE. Changes outcome of
  [`fix_dating()`](https://lsteinmann.github.io/idaifieldR/reference/fix_dating.md).

- silent:

  TRUE/FALSE, default: FALSE. Should messages be suppressed?

## Value

A single resource (element) for an `idaifield_resources`-list.

## Examples

``` r
if (FALSE) { # \dontrun{
simpler_resource <- simplify_single_resource(resource,
replace_uids = TRUE,
uidlist = uidlist,
keep_geometry = FALSE)
} # }
```
