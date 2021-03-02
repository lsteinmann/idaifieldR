#' get_idaifield_docs
#'
#' Imports all resources from an idaifield-database that is currently running
#' and synching into a list-object for further processing in R. Please note that
#' Synching has to be activated in `idaifield` itself (Settings -> Synchronisation).
#'
#' This just wraps `sofa`s functions under another name, but with defaults that
#' are useful for the import from `idaifield`. Also, I am using unnest_resource() from
#' this package here, as there seems to be no use in the unnested version.
#'
#' (todo: maybe I can add an option to have it unnested.)
#'
#'
#' @param serverip The IP that the user can find in `idaifield`s settings as "Eigene Adresse" without the port-specification
#'
#' @param projectname The name of the project in `idaifield` that one wished to load.
#'
#' @param user A user name (anything works, really.)
#'
#' @param pwd The Password as it is displayed in the `idaifield`-settings as "Eigenes Passwort"
#'
#' @param port The port that is specified by `idaifield`s setting below "Eigene Adresse"
#' (the format there would be: "http://192.168.2.21:3000") and port refers to the number befind ":".
#' There is no need to specify this as the default works. Included for fringe-cases.
#'
#' @param simplified Defaults to TRUE. If you do not wish to automatically unnest (i.e. remove
#' a level of the list that contains some metadata which is IMO not useful when processing in R)
#' just put FALSE (or anything but TRUE). If you wish to take a look at it and then later unnest, you can always
#' use unnest_resource() from this package.
#'
#' @return
#' @export
#'
#' @examples
get_idaifield_docs <- function(serverip    = "192.168.1.199",
                               projectname = "projektname",
                               user        = "Anna Allgemeinperson",
                               pwd         = "password",
                               port        = 3000,
                               simplified  = TRUE) {
  idaifield_connection <- sofa::Cushion$new(host = serverip,
                                            transport = "http",
                                            port = port,
                                            user = user,
                                            pwd = pwd)
  sofa::db_info(idaifield_connection, projectname)
  idaifield_docs <- sofa::db_alldocs(idaifield_connection, projectname, include_docs = TRUE)$rows
  idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")


  if (simplified) {
    idaifield_docs <- unnest_resource(idaifield_docs)
  }

  return(idaifield_docs)
}
