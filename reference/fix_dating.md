# Reduce the Dating-list to *min*/*max*-Values

Reformats the "dating"-list of any resource from an `idaifield_docs`- or
`idaifield_resources`-list to contain min and max dating and additional
info as well as the original values in the "comment"-element.

## Usage

``` r
fix_dating(dat_list, use_exact_dates = FALSE)
```

## Arguments

- dat_list:

  A "dating"-list of any resource from an `idaifield_docs`- or
  `idaifield_resources`-list.

- use_exact_dates:

  TRUE/FALSE: If TRUE and "exact" dating type is present, sets the min
  and max dating to the value of the exact dating. Default is FALSE.

## Value

A reformatted list containing min and max dating and additional
information as well as all original values in the "comment"-element. If
`use_exact_dates = TRUE` contains the value of the exact dating in both
*dating.min* and *dating.max*.

## See also

- This function is used by:
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
dat_list <- list(list(type = "range",
                     begin = list(inputYear = 2000, inputType = "bce"),
                     end = list(inputYear = 2000, inputType = "ce")),
                list(type = "exact",
                     begin = list(inputYear = 130, inputType = "bce"),
                     end = list(inputYear = 130, inputType = "bce")))
# Use the true min/max dating:
fix_dating(dat_list)
# use the available exact dating:
fix_dating(dat_list, use_exact_dates = TRUE)
} # }
```
