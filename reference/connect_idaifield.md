# Connect to an iDAI.field / Field Desktop Client

This function establishes a connection to the database of your
[iDAI.field / Field Desktop
Client](https://github.com/dainst/idai-field), and returns a connection
object containing the necessary information for other functions to
access the database, such as
[`get_idaifield_docs()`](https://lsteinmann.github.io/idaifieldR/reference/get_idaifield_docs.md),
[`idf_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_query.md),
[`idf_index_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
or
[`idf_json_query()`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).

## Usage

``` r
connect_idaifield(
  serverip = "localhost",
  project = NULL,
  pwd = "password",
  ping = TRUE
)
```

## Arguments

- serverip:

  The IP address of the Field Client, or "localhost". Leave the default
  if you are using Field Desktop on the same computer.

- project:

  (*required*) The name of the project you want to work with. For a list
  of available projects, see
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md).

- pwd:

  (*required*) The password used to authenticate with the Field Client
  (default is "password").

- ping:

  Should the connection be pinges on creation? Defaults to TRUE.

## Value

`connect_idaifield()` returns an `idf_connection_settings` object that
is used by other functions in this package to retrieve data from the
[iDAI.field / Field Desktop
Client](https://github.com/dainst/idai-field).

## Details

By default, if you are using Field Desktop on the same machine, you
should not need to specify the `serverip` argument, as it defaults to
"localhost". If you want to access a client on the same network that is
not running on the same computer as R, you can supply the local IP
(without the port (':3000')). The `pwd` argument needs to be set to the
password that is set in your Field Desktop Client under
*Tools/Werkzeuge* \> *Settings/Einstellungen*: 'Your password'/'Eigenes
Passwort'. `project` has to be set to the identifier of the project
database you will query.

## See also

- Ping the connection with
  [`idf_ping()`](https://lsteinmann.github.io/idaifieldR/reference/idf_ping.md)

- Get a list of projects in the database with
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(
  serverip = "localhost",
  pwd = "hallo",
  project = "rtest"
)

conn$status

idf_ping(conn)
} # }
```
