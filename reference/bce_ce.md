# Translate a Dating Value from iDAI.field to a Positive or Negative Number

This function takes a list containing a numerical year and a type of
dating (either "bce", "ce", or "bp") and returns the year as a number
with a positive or negative sign indicating whether the year is BCE or
CE. If the dating type is "bp", the year is subtracted from 1950 to get
a BCE year.

## Usage

``` r
bce_ce(list)
```

## Arguments

- list:

  A named list containing at least the following elements:

  inputYear

  :   A numerical value representing a year.

  inputType

  :   A character string indicating the type of dating for the inputYear
      value. Must be one of "bce", "ce", or "bp".

## Value

A numerical value representing the year, with a negative sign indicating
BCE and a positive sign indicating CE. The `warning` attribute carries
over possible warnings.

## See also

[`fix_dating()`](https://lsteinmann.github.io/idaifieldR/reference/fix_dating.md)

## Examples

``` r
if (FALSE) { # \dontrun{
list <- list(inputYear = 100, inputType = "bce")
bce_ce(list)
} # }
```
