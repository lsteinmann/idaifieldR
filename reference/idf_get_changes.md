# See when and by whom selected resources have been created or modified

See when and by whom selected resources have been created or modified

## Usage

``` r
idf_get_changes(connection, ids)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- ids:

  A vector of either **identifier**s or **UUID**s of resources for which
  the changes should be returned.

## Value

A data.frame in which each row corresponds to a change made to the
resource named in the *identifier* column at the time stated in the
*date* column by the user stated in the *user* column. In the *action*
column, the value can either be *created* referring to the date of first
creation of the resource, or *modified* referring to the date when it
was changed.

## See also

- [`idf_last_changed()`](https://lsteinmann.github.io/idaifieldR/reference/idf_last_changed.md)

## Examples

``` r
if (FALSE) { # \dontrun{
connection <- connect_idaifield(pwd = "hallo", project = "rtest")
index <- get_field_index(connection)
last_changed <- idf_last_changed(
    connection = connection,
    index = index,
    n = 100
)
changes_df <- idf_get_changes(connection, ids = last_changed)
} # }
```
