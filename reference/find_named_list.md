# Return a sub-list from a nested list by name

Return a sub-list from a nested list by name

## Usage

``` r
find_named_list(nested_list = NULL, target_name = NULL)
```

## Arguments

- nested_list:

  a nested list

- target_name:

  a character value expected to be the name of one list

## Value

The first sub-list that has the name passed to target_name.

## Examples

``` r
list <- list(
  first1 = list(
    second1 = list(1, 2, 3),
    second2 = list(4, 5, 6)
    ),
  first2 = list(7, 8, 9)
)
find_named_list(list, "second2")
#> [[1]]
#> [1] 4
#> 
#> [[2]]
#> [1] 5
#> 
#> [[3]]
#> [1] 6
#> 
```
