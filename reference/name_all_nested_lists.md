# Recursively Assign Names to All Nested Lists Based on "name" Field

This function recursively traverses a nested list structure and assigns
names to unnamed sub-lists based on their `name` field or the `name`
field contained within an `item` sublist. It only assigns names if the
list doesn't already have names.

## Usage

``` r
name_all_nested_lists(lst)
```

## Arguments

- lst:

  A nested list structure, where sublists may contain an `item` sublist
  or a `name` field.

## Value

The same nested list structure, but with unnamed sublists assigned names
based on the `name` or `item$name` field values.

## Details

The function looks for the following naming rules:

1.  If a sublist contains an `item` sublist and that `item` sublist has
    a `name` field, the parent sublist is named based on the `item$name`
    value.

2.  If a sublist contains a `name` field directly, the parent sublist is
    named based on the `name` value.

3.  If neither `item$name` nor `name` exists, the sublist remains
    unnamed.

The function continues to apply these rules recursively to all sublists,
ensuring that all unnamed sublists are appropriately named based on the
above criteria.

## Examples

``` r
if (FALSE) { # \dontrun{
test <- list(
  list(item = list(name = "1", value = "value1"), groups = list(
    list(name = "1a", fields = list(list(name = "1a-1"), list(name = "1a-2"))),
    list(name = "1b", fields = list(list(name = "1b-1"), list(name = "1b-2")))
  )),
  list(item = list(name = "2", value = "value1")),
  list(item = list(name = "3", value = "value1"), groups = list(
    list(name = "3a", fields = list(list(name = "3a-1"), list(name = "3a-2"))),
    list(name = "3b", fields = list(list(name = "3b-1"), list(name = "3b-2")))
  ))
)
named_list <- name_all_nested_lists(test)
print(named_list)
} # }
```
