# Checks if a list has sub-lists and returns TRUE if so

Checks if a list has sub-lists and returns TRUE if so

## Usage

``` r
check_for_sublist(single_resource_field)
```

## Arguments

- single_resource_field:

  a list to be checked

## Value

TRUE/FALSE

## Examples

``` r
if (FALSE) { # \dontrun{
list <- list(1, 2, 3, list("börek", 2, 3))

check_for_sublist(list)
} # }
```
