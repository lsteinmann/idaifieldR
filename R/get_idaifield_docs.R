#' get_idaifield_docs
#'
#' Imports all resources from an idaifield-database that is currently running
#' and synching into a list-object for further processing in R.
#' This just wraps **sofa**s functions under another name,
#' but with defaults that are useful for the import from iDAI.field 2.
#' Also, I am using unnest_resource() from this package here, as there
#' seems to be no use in the unnested version. However,
#' simplified = FALSE would allow to get the top-level version.
#'
#' NOTE: If you are planning on using the coordinates stored in the database,
#' I strongly suggest you consider changing your R digits-setting to a higher
#' value than the default. Depending on the projection used, coordinates may
#' be represented by rather long numbers which R might automatically round on
#' import. `options(digits = 20)` should do the trick. (That applies to
#' other fields containing long numbers as well.)
#'
#'
#' @param serverip The IP that the user can find in iDAI.field 2's settings as
#' "Eigene Adresse" without the port-specification
#'
#' @param projectname The name of the project in iDAI.field 2 that one
#' wishes to load.
#'
#' @param user A user name (anything works, really.)
#'
#' @param pwd The Password as it is displayed in the iDAI.field 2-settings
#' as "Eigenes Passwort"
#'
#' @param port The port that is specified by iDAI.field 2's setting below
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
#' conn <- connect_idaifield(serverip = "192.168.2.21",
#' user = "R", pwd = "hallo")
#' idaifield_docs <- get_idaifield_docs(connection = conn,
#' projectname = "testproj")
#' }
#'
get_idaifield_docs <- function(connection = connect_idaifield(...),
                               projectname = "projektname",
                               simplified  = TRUE) {

  idaifield_docs <- sofa::db_alldocs(connection, projectname,
                                     include_docs = TRUE)$rows
  idaifield_docs <- structure(idaifield_docs, class = "idaifield_docs")

  if (simplified) {
    idaifield_docs <- unnest_resource(idaifield_docs)
  }
  return(idaifield_docs)
}
