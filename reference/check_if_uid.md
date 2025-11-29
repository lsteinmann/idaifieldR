# Check if the vector/object is a UUID

Check if the vector/object is a UUID

## Usage

``` r
check_if_uid(string)
```

## Arguments

- string:

  A character string or vector of character strings that should be
  checked for being a UID as used in iDAI.field 2 / Field Desktop

## Value

a vector of the same length as string containing TRUE if the
corresponding item in string is a UID, FALSE if not

## Examples

``` r
if (FALSE) { # \dontrun{
check_if_uid(string = "0324141a-8201-c5dc-631b-4dded4552ac4")
check_if_uid(string = "not a uid")
} # }
```
