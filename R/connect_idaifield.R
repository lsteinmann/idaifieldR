#' Establishes a connection to the iDAI.field 2 Client.
#'
#' @param serverip The IP that the user can find in iDAI.field 2's settings as
#' "Eigene Adresse" without the port-specification
#' @param user A user name (anything works, really.)
#' @param pwd The Password as it is displayed in the iDAI.field 2-settings
#' as "Eigenes Passwort"
#'
#' @return a connection object
#' @export
#'
#' @examples
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
connect_idaifield <- function(serverip    = "127.0.0.1",
                              user        = "Anna Allgemeinperson",
                              pwd         = "password") {


  idaifield_connection <- sofa::Cushion$new(host = serverip,
                                            transport = "http",
                                            port = 3000,
                                            user = user,
                                            pwd = pwd)

  return(idaifield_connection)
}
