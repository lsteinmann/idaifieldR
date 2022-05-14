#' Establishes a connection to the iDAI.field 2 / Field Desktop Client.
#'
#' @param serverip The IP that the user can find in the Field Clients settings as
#' "Eigene Adresse" without the port-specification
#' @param user A user name (anything works, really.)
#' @param pwd The Password as it is displayed in the Field Clients settings
#' as "Eigenes Passwort"
#' @param version 2 if iDAI.field 2 is used, 3 if you are using
#' Field Desktop (default, integer).
#'
#' @return a connection object
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

  return(idaifield_connection)
}
