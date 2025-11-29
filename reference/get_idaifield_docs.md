# Import all *docs* from an iDAI.field / Field Desktop project

Imports all *docs* from an iDAI.Field-database that is currently running
and syncing into a list-object for further processing in R. The function
is only useful for the import from [iDAI.field 2 or Field
Desktop](https://github.com/dainst/idai-field) with the respective
client running on the same computer or in the same network as the
R-script.

## Usage

``` r
get_idaifield_docs(
  connection = connect_idaifield(serverip = "127.0.0.1", project = "rtest", user = "R",
    pwd = "hallo"),
  raw = TRUE,
  json = FALSE,
  projectname = NULL
)
```

## Arguments

- connection:

  A connection object as returned by
  [`connect_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/connect_idaifield.md)

- raw:

  TRUE/FALSE. Should the result already be unnested to resource level
  using
  [`check_and_unnest()`](https://lsteinmann.github.io/idaifieldR/reference/check_and_unnest.md)?
  (Default is FALSE.)

- json:

  TRUE/FALSE. Should the function return a JSON-character string?
  (Default is FALSE.) If TRUE output cannot be processed with the
  functions from this package. Can be parsed using e.g.
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

- projectname:

  (deprecated) The name of the project in the Field Client that one
  wishes to load. Will overwrite the project set in the
  `connection`-object. See
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md)
  for all available projects.

## Value

an object (list) of class `idaifield_docs` if `raw = TRUE` and
`idaifield_resources` if `raw = FALSE` that contains all
*docs*/*resources* in the selected project except for the project
configuration. The `connection` and `projectname` are attached as
attributes for later use. (If `json = TRUE`, returns a character string
in JSON-format.)

## Details

When using `raw = TRUE` (the default) this function will allow you to
get the change log for each resource, i.e. which user changed something
in the resource at what time and who created it. Setting `raw = FALSE`
will only return a list of the actual data. You can do this at a later
time using
[`check_and_unnest()`](https://lsteinmann.github.io/idaifieldR/reference/check_and_unnest.md)
from this package. NOTE: If you are planning on using the coordinates
stored in the database, I strongly suggest you consider changing your R
digits-setting to a higher value than the default. Depending on the
projection used, coordinates may be represented by rather long numbers
which R might automatically round on import. `options(digits = 20)`
should more than do the trick. (That applies to other fields containing
long numbers as well.)

## See also

- For querying the database:
  [`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),[`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
  [`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md)

- For filtering / selecting an `idaifield_docs`- or
  `idaifield_resources`-list:
  [`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md)

- For processing the list:
  [`check_and_unnest()`](https://lsteinmann.github.io/idaifieldR/reference/check_and_unnest.md),
  [`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(project = "rtest", pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = conn)
} # }
```
