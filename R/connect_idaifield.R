#' Establish a connection to the iDAI.field / Field Desktop Client
#'
#' The connection-object is used to establish a connection to the database of
#' you iDAI.field / Field Desktop Client. It contains all the information needed
#' to access the database using other functions such as `get_idaifield_docs()`.
#'
#' If you are using Field Desktop on the same machine, you should not need
#' the `serverip`-argument, as it defaults to the common localhost address.
#' Likewise, the `user`-argument is currently not needed for access.
#' `pwd` needs to be the password that is set in your Field Desktop-Client
#' under Tools/Werkzeuge > Settings/Einstellungen:
#' 'Your password'/'Eigenes Passwort'. If the default `serverip`-argument
#' does not work for you, or you want to access a Client on the same network
#' that is not running on the same machine as R, you can exchange it for the
#' address listed above the password (without the port (':3000')).
#' The `version`-argument does not need to be specified if you use the
#' current version of Field Desktop (3), but will help you connect if you
#' are using 'iDAI.field 2'.
#'
#'
#' @param serverip The IP that the user can find in the Field Clients settings as
#' 'Your address'/'Eigene Adresse' without the port-specification (':3000')
#' @param user (optional) A user name. This should currently not be needed.
#' @param pwd The Password as it is displayed in the Field Clients settings
#' as 'Your password'/'Eigenes Passwort'
#' @param version 2 if iDAI.field 2 is used, 3 if you are using
#' Field Desktop (default 3, integer).
#'
#' @return a `sofa`-connection object (`Cushion`)
#' @export
#'
#' @examples
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
connect_idaifield <- function(serverip    = "127.0.0.1",
                              user        = "Anna Allgemeinperson",
                              pwd         = "password",
                              version     = 3) {

  # set version to numeric if possible
  if (!is.numeric(version)) {
    version <- suppressWarnings(as.numeric(version))
  }
  # error if that didnt work
  if (is.na(version)) {
    stop("Please enter a valid version number (integer)")
  }
  # use result to set the port according to the version
  if (version >= 3) {
    port <- 3001
  } else {
    port <- 3000
  }

  idaifield_connection <- sofa::Cushion$new(host = serverip,
                                            transport = "http",
                                            port = port,
                                            user = user,
                                            pwd = pwd)

  fail <- idf_ping(idaifield_connection)
  if(is.character(fail)) {
    warning(fail)
  }

  return(idaifield_connection)
}
