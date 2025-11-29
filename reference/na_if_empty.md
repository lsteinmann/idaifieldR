# Returns NA if an object handed to the function is empty

This is a helper function in defence against empty list items from
iDAI.field 2 / Field Desktop, which sometimes occur. It simply writes NA
in the corresponding field if a list or any kind of object handed to it
is of length 0. Otherwise, it returns the input untouched.

## Usage

``` r
na_if_empty(item)
```

## Arguments

- item:

  any object whatsoever

## Value

NA if empty, or the object that has been handed to it

## Examples

``` r
if (FALSE) { # \dontrun{
na_if_empty(1)
na_if_empty(list(2,3,4,list(4,5,4)))
na_if_empty(NULL)
} # }
```
