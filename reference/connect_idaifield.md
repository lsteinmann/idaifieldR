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
  serverip = "127.0.0.1",
  project = NULL,
  user = "R",
  pwd = "password",
  version = 3,
  ping = TRUE
)
```

## Arguments

- serverip:

  The IP address of the Field Client. If you are using Field Desktop on
  the same machine, the default value (*127.0.0.1*) should usually work.

- project:

  (*required*) The name of the project you want to work with. For a list
  of available projects, see
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md).

- user:

  (*optional*) The username for the connection. This parameter is not
  currently needed.

- pwd:

  (*required*) The password used to authenticate with the Field Client
  (default is "password").

- version:

  The version number of the Field Client. By default, the value is set
  to 3.

- ping:

  logical. Whether to test the connection on creation (default is TRUE).
  If TRUE, `connect_idaifield()` also checks if the project exists.

## Value

`connect_idaifield()` returns an `idf_connection_settings` object that
contains the connection settings needed to connect to the database of
your [iDAI.field / Field Desktop
Client](https://github.com/dainst/idai-field).

## Details

By default, if you are using Field Desktop on the same machine, you
should not need to specify the `serverip` argument, as it defaults to
the common localhost address. Similarly, the `user` argument is
currently not needed for access. The `pwd` argument needs to be set to
the password that is set in your Field Desktop Client under
*Tools/Werkzeuge* \> *Settings/Einstellungen*: 'Your password'/'Eigenes
Passwort'. If the default `serverip` argument does not work for you, or
you want to access a client on the same network that is not running on
the same machine as R, you can exchange it for the address listed above
the password (without the port (':3000')). The `version` argument does
not need to be specified if you are using the current version of Field
Desktop (3), but will help you connect if you are using *iDAI.field 2*.
You can set the `project` that you want to work with in this function,
but be aware that other functions will overwrite this setting if you
supply a project name there. `connect_idaifield()` will check if the
project actually exists and throw an error if it does not.

## See also

- Ping the connection with
  [`idf_ping()`](https://lsteinmann.github.io/idaifieldR/reference/idf_ping.md)

- Get a list of projects in the database with
  [`idf_projects()`](https://lsteinmann.github.io/idaifieldR/reference/idf_projects.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_idaifield(
  serverip = "127.0.0.1",
  user = "R",
  pwd = "hallo",
  project = "rtest"
)

conn$status

idf_ping(conn)
} # }
```
