# Simplify a List Imported from an iDAI.field / Field Desktop-`1041-1`\#' Simplify a List Imported from an iDAI.field / Field Desktop-Database

The function will take a list as returned by
[`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
[`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
[`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
or
[`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md)
and process it to make the list more usable. It will unnest a few lists,
including the dimension-lists and the period-list to provide single
values for later processing with
[`idaifield_as_matrix()`](https://lsteinmann.github.io/idaifieldR/reference/idaifield_as_matrix.md).
If a connection to the database can be established, the function will
get the relevant project configuration and convert custom
checkboxes-fields to multiple lists, each for every value from the
respective valuelist, to make them more accessible during the conversion
with
[`idaifield_as_matrix()`](https://lsteinmann.github.io/idaifieldR/reference/idaifield_as_matrix.md).
It will also remove the custom configuration field names that are in use
since iDAI.field 3 / Field Desktop and consist of
"projectname:fieldName". Only the "projectname:"-part will be removed.

## Usage

``` r
simplify_idaifield(
  idaifield_docs,
  keep_geometry = FALSE,
  replace_uids = TRUE,
  find_layers = TRUE,
  uidlist = NULL,
  language = "all",
  remove_config_names = TRUE,
  spread_fields = TRUE,
  use_exact_dates = FALSE,
  silent = FALSE
)
```

## Arguments

- idaifield_docs:

  An `idaifield_docs` or `idaifield_resources`-list as returned by
  [`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md)
  or
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
  [`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
  and
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

- keep_geometry:

  TRUE/FALSE: Should the geographical information be kept or removed?
  Defaults is FALSE. Uses:
  [`reformat_geometry()`](https://lsteinmann.github.io/idaifieldR/reference/reformat_geometry.md)

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
  This only makes sense if the list handed to `simplify_idaifield()` had
  not been selected yet. If it has been, you should supply a data.frame
  as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md).

- language:

  The short name (e.g. "en", "de", "fr") of the language that is
  preferred for the fields. Special value "all" (the default) can be
  used to return a concatenated string of all available languages.
  [`gather_languages()`](https://lsteinmann.github.io/idaifieldR/reference/gather_languages.md)
  will select other available languages in alphabetical order if the
  selected language is not available.

- remove_config_names:

  TRUE/FALSE: Should the name of the project be removed from field names
  of the configuration? (Default is TRUE.) (Should e.g.: *test:amount*
  be renamed to *amount*, see
  [`remove_config_names()`](https://lsteinmann.github.io/idaifieldR/reference/remove_config_names.md).)

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

An `idaifield_simple`-list containing the same resources in a different
format depending on the parameters used.

## Details

Please note: The function will need an Index (i.e. uidlist as provided
by
[`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md))
of the complete project database to correctly replace the UUIDs with
their corresponding identifiers! Especially if a selected list is passed
to `simplify_idaifield()`, you need to supply the uidlist of the
complete project database as well.

Formatting of various lists: Dimension measurements as well as dating
are reformatted and might produce unexpected results. For the dating,
all begin and end values are evaluated and for each resource, the
minimum value from "begin" and maximum value from "end" is selected. For
the dimension-fields, if a ranged measurement was selected, a mean will
be returned.

## See also

- This function uses:
  [`idf_sepdim()`](https://lsteinmann.github.io/idaifieldR/reference/idf_sepdim.md),
  [`remove_config_names()`](https://lsteinmann.github.io/idaifieldR/reference/remove_config_names.md)

- When find_layers = TRUE:
  [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md),
  this only works when the function can get an index/uidlist!

- [`fix_dating()`](https://lsteinmann.github.io/idaifieldR/reference/fix_dating.md)
  with the outcome depending on the `use_exact_dates`-argument.

- When selecting a language:
  [`gather_languages()`](https://lsteinmann.github.io/idaifieldR/reference/gather_languages.md)

- Depending on the `spread_fields`-argument:
  [`convert_to_onehot()`](https://lsteinmann.github.io/idaifieldR/reference/convert_to_onehot.md)

- Depending on the `keep_geometry`-argument:
  [`reformat_geometry()`](https://lsteinmann.github.io/idaifieldR/reference/reformat_geometry.md)

- Depending on the `replace_uids`-argument:
  [`fix_relations()`](https://lsteinmann.github.io/idaifieldR/reference/fix_relations.md)
  with
  [`replace_uid()`](https://lsteinmann.github.io/idaifieldR/reference/replace_uid.md)

- If `uidlist = NULL`:
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(serverip = "127.0.0.1",
    project = "rtest",
    user = "R",
    pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = connection)

simpler_idaifield <- simplify_idaifield(idaifield_docs)
} # }
```
