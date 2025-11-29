# returns the category of the ids (UUID/identifier)

returns the category of the ids (UUID/identifier)

## Usage

``` r
find_categories(ids, uidlist, id_type)
```

## Arguments

- uidlist:

  A data.frame as returned by
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)
  or
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md).

- id_type:

  One of "identifier" or "UID" - Should the function use *identifier*s
  or *UUID*s to find the layer?

## Value

a vector of categories for each resource

## See also

- [`find_layer()`](https://lsteinmann.github.io/idaifieldR/reference/find_layer.md).
