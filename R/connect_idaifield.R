#' Establish a connection to the iDAI.field / Field Desktop Client
#'
#' The connection-object is used to store the connection settings needed to
#' connect to the database of your iDAI.field / Field Desktop Client.
#' It contains all the information that other functions such
#' as `get_idaifield_docs()` need access the database.
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
#' are using 'iDAI.field 2'. You can set the `project` that you want to work
#' with in this function, but be aware that other functions will overwrite
#' this setting if you supply a projectname there. `connect_idaifield()` will
#' check if the project actually exists and throw an error if it does not.
#'
#'
#' @param serverip The IP that the user can find in the Field Clients settings as
#' 'Your address'/'Eigene Adresse' without the port-specification (':3000')
#' @param project character. The project you want to work with. Will be
#' overwritten by the projectname specification in other functions. If not
#' supplied to other function, they will use the project recorded in the
#' connection object.
#' @param user (optional) A user name. This should currently not be needed.
#' @param pwd The Password as it is displayed in the Field Clients settings
#' as 'Your password'/'Eigenes Passwort'
#' @param version 2 if iDAI.field 2 is used, 3 if you are using
#' Field Desktop (default 3, integer).
#' @param ping logical. default TRUE; Should the connection be tested on
#' creation? If TRUE, also checks if the project exists.
#'
#' @return an `idaifieldR`-connection settings object (`idf_connection_settings`)
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1",
#' user = "R", pwd = "hallo")
#' }
connect_idaifield <- function(serverip    = "127.0.0.1",
                              project     = NULL,
                              user        = "Anna Allgemeinperson",
                              pwd         = "password",
                              version     = 3,
                              ping        = TRUE) {


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

  headers <- list(`Content-Type` = "application/json",
                  Accept = "application/json")
  auth <- crul::auth(user = user, pwd = pwd)

  base_url <- paste0("http://", serverip, ":", port)

  settings <- list(headers = headers,
                   base_url = base_url,
                   auth = auth)

  status <- NA
  conn <- list(status = status, project = project, settings = settings)
  conn <- structure(conn, class = "idf_connection_settings")

  if (ping) {
    conn$status <- idf_ping(conn)
    if (conn$status && !is.null(project)) {
      choices <- suppressMessages(idf_projects(conn))
      project_present <- project %in% choices
      if (!project_present) {
        stop(paste0("Invalid project: '", project, "'. Choose one of: ", paste(choices, collapse = ", ")))
      }
    }
  }

  return(conn)
}

#' Connection-Client to a Field Database to get all docs (internal)
#'
#' @param conn The connection settings as returned by `connect_idaifield()`
#' @param project character. Name of the project-database that should be loaded.
#'
#' @return a crul::HttpClient
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   connection <- connect_idaifield(pwd = "hallo", project = "rtest")
#'   client <- proj_idf_client(conn = connection)
#' }
proj_idf_client <- function(conn, project = NULL, include = "all") {
  if (!inherits(conn, "idf_connection_settings")) {
    stop("Need an 'idf_connection_settings'-object as returned by `connect_idaifield()`.")
  }

  include <- match.arg(include, c("all", "query"), several.ok = FALSE)

  if (is.na(conn$status)) {
    message("Status not set. Attempting to reach database...")
    conn$status <- idf_ping(conn)
  }
  if (!conn$status) {
    message("Status set to FALSE. Attempting to reach database...")
    conn$status <- try(idf_ping(conn), silent = TRUE)
    conn$status <- ifelse(inherits(conn$status, "try-error"), FALSE, conn$status)
  }

  if (is.null(project) & !is.null(conn$project)) {
    project <- conn$project
  }

  if (is.null(project)) {
    stop("Supply a project either here or in the connection settings (`connect_idaifield()`)!")
  } else {
    url <- paste0(conn$settings$base_url, "/", project)
  }

  if (conn$status) {
    proj_conn <- crul::HttpClient$new(url = url,
                                      opts = conn$settings$auth,
                                      headers = conn$settings$headers)

    message <- jsonlite::fromJSON(proj_conn$get()$parse("UTF-8"), FALSE)
    message <- paste0("Connected to project '", message$db_name,
                      "' containing ", message$doc_count, " docs.")

    message(message)
  } else {
    stop("Could not reach database - check the connection settings.")
  }
  if (include == "all") {
    url <- paste0(url, "/_all_docs")
  } else if (include == "query") {
    url <- paste0(url, "/_find")
  }

  proj_conn <- crul::HttpClient$new(url = url,
                                    opts = conn$settings$auth,
                                    headers = conn$settings$headers)

  return(proj_conn)
}

#' Ping the Field-Database
#'
#' Helper for all functions that access the database to display
#' specific warning messages.
#'
#' @param conn The connection settings as returned by `connect_idaifield()` or
#' a direct Client as returned by `proj_idf_client()` for internal functions
#'
#' @return returns TRUE if connection works, FALSE if failed to connect
#' @export
#'
#' @examples
#' \dontrun{
#' idaifield_connection <- connect_idaifield(ping = FALSE)
#' idf_ping(idaifield_connection)
#' }
#'
idf_ping <- function(conn) {
  if (inherits(conn, "idf_connection_settings")) {
    conn <- crul::HttpClient$new(url = conn$settings$base_url,
                                 opts = conn$settings$auth,
                                 headers = conn$settings$headers)
  }
  if (inherits(conn, "HttpClient")) {
    ping <- try(conn$get()$parse("UTF-8"), silent = TRUE)
    if(inherits(ping, "try-error")) {
      # throw error when curl "Could not resolve host"
      stop(paste0(ping[1], "\nCheck the connection settings from 'connect_idaifield()' and try again."))
    } else if (grepl("Welcome!", ping)) {
      # return true if connection works
      ping <- jsonlite::fromJSON(ping)
      message(ping[[1]])
      return(TRUE)
    } else {
      # return FALSE if connection does not work for expected reasons
      ping <- jsonlite::fromJSON(ping)
      ping <- paste0(unlist(ping, use.names = FALSE), collapse = ": ")
      warning(ping)
      return(FALSE)
    }
  } else {
    # return FALSE if passed object was not a connection
    warning("Did nothing. Supply an 'idf_connection_settings'-object as returned by `connect_idaifield()` or a crul 'HttpClient'.)")
    return(FALSE)
  }
}


