# takes and returns a parent list recursively until as much as possible is solved

takes and returns a parent list recursively until as much as possible is
solved

## Usage

``` r
find_parent_layer(
  parent_list,
  index,
  id_type,
  layer_categories,
  max_depth = 20
)
```

## Arguments

- parent_list:

  a list with solved and unsolved resources

- index:

  A data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  or
  [`make_index()`](https://lsteinmann.github.io/idaifieldR/reference/make_index.md).

- id_type:

  One of "identifier" or "UID" - Should the function use *identifier*s
  or *UUID*s to find the layer?

- layer_categories:

  A vector of *categories* that are classified as *Layer*s.

- max_depth:

  numeric. Maximum number of recursive iterations / maximum depth a
  resource may be nested below its layer.

## Value

a list with solved and unsolved resources

## See also

- [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md).
