# Get a vector of *Place*-resources each element from the index is located in

Get a vector of *Place*-resources each element from the index is located
in

## Usage

``` r
gather_trenches(uidlist)
```

## Arguments

- uidlist:

  as returned by
  [`get_uid_list()`](https://lsteinmann.github.io/idaifieldR/reference/get_uid_list.md)
  and
  [`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md)

## Value

a vector containing the Place each resource is located in

## Examples

``` r
if (FALSE) { # \dontrun{
uidlist$Place <- gather_trenches(uidlist)
} # }
```
