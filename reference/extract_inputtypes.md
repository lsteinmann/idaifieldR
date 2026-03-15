# Extract a List of inputTypes from the Project Configuration

Internal recursive helper to
[`parse_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/parse_field_inputtypes.md).
Traverses the nested `categories` / `trees` structure of an
`idaifield_config` and collects one entry per field, recording its
category, parent supercategory, field name, and inputType.

## Usage

``` r
extract_inputtypes(nested_list, parent_name = NULL, category_name = NULL)
```

## Arguments

- nested_list:

  A configuration list as returned by
  [`get_configuration()`](https://lsteinmann.github.io/idaifieldR/reference/get_configuration.md),
  or a sub-list thereof during recursion.

- parent_name:

  Character. Name of the supercategory currently being processed. `NULL`
  on the initial call; set internally during recursion.

- category_name:

  Character. Name of the (sub)category currently being processed. `NULL`
  on the initial call; set internally during recursion.

## Value

A list of named lists, each with elements `category`, `parent`,
`fieldname`, and `inputType`, one entry per field found. Returns `NULL`
if no fields are found.

## Details

The config tree has two levels of nesting that matter here:

- Top level (`categories`): supercategories (e.g. `Operation`, `Find`).

- Second level (`trees`): subcategories (e.g. `Trench` inside
  `Operation`).

Fields live inside `item$groups[[group]]$fields`. The function visits
both levels and records `parent` as the supercategory in both cases.

## See also

[`parse_field_inputtypes()`](https://lsteinmann.github.io/idaifieldR/reference/parse_field_inputtypes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(serverip = "localhost",
                          pwd = "hallo",
                          project = "rtest")
config <- get_configuration(connection = conn)
input_types <- extract_inputtypes(config)
} # }
```
