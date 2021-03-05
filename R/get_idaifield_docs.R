#' get_idaifield_docs
#'
#' Imports all resources from an idaifield-database that is currently running
#' and synching into a list-object for further processing in R.
#' Please note that synching has to be activated in i.DAIfield 2
#' itself (Settings -> Synchronisation).
#'
#' This just wraps **sofa**s functions under another name,
#' but with defaults that are useful for the import from i.DAIfield 2.
#' Also, I am using unnest_resource() from this package here, as there
#' seems to be no use in the unnested version. However,
#' simplified = FALSE would allow to get the top-level version.
#'
#'
#' @param serverip The IP that the user can find in i.DAIfield 2's settings as
#' "Eigene Adresse" without the port-specification
#'
#' @param projectname The name of the project in i.DAIfield 2 that one
#' wishes to load.
#'
#' @param user A user name (anything works, really.)
#'
#' @param pwd The Password as it is displayed in the i.DAIfield 2-settings
#' as "Eigenes Passwort"
#'
#' @param port The port that is specified by i.DAIfield 2's setting below
#' "Eigene Adresse" (the format there would be: "http://192.168.2.21:3000")
#' and port refers to the number behind ":". There is no need to specify this
#' as the default works. Included for fringe-cases.
#'
#' @param simplified Defaults to TRUE. If you do not wish to automatically
#' unnest (i.e. remove a level of the list that contains some metadata which is
#' IMO not useful when processing in R) just put FALSE (or anything but TRUE).
#' If you wish to take a look at it and then later unnest, you can always use
#' unnest_resource() from this package.
#'
#' @return an object (list) of class "idaifield_docs" (if simplified = FALSE)
#' or "idaifield_resources" (if simplified = TRUE) that contains the
#' resources in the selected project.
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
#' projectname = "testproj",
#' user = "R",
#' pwd = "password")
#' }
#'
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
  idaifield_docs <- sofa::db_alldocs(idaifield_connection, projectname,
                                     include_docs = TRUE)$rows
  idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")


  if (simplified) {
    idaifield_docs <- unnest_resource(idaifield_docs)
  }

  return(idaifield_docs)
}
