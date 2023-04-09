#' Connect to iDAI.field / Field Desktop Client
#'
#' @description This function establishes a connection to the database of your
#' iDAI.field / Field Desktop Client, and returns a connection object
#' containing the necessary information for other functions to access
#' the database, such as \code{\link{get_idaifield_docs}},
#' \code{\link{idf_query}} or  \code{\link{idf_index_query}}.
#'
#' @details By default, if you are using Field Desktop on the same machine,
#' you should not need to specify the `serverip` argument, as it defaults to
#' the common localhost address. Similarly, the `user` argument
#' is currently not needed for access. The `pwd` argument needs to be
#' set to the password that is set in your Field Desktop Client under
#' Tools/Werkzeuge > Settings/Einstellungen: 'Your password'/'Eigenes Passwort'.
#' If the default `serverip` argument does not work for you,
#' or you want to access a client on the same network that is not running
#' on the same machine as R, you can exchange it for the address listed above
#' the password (without the port (':3000')). The `version` argument does
#' not need to be specified if you are using the current version of
#' Field Desktop (3), but will help you connect if you are using 'iDAI.field 2'.
#' You can set the `project` that you want to work with in this function,
#' but be aware that other functions will overwrite this setting if
#' you supply a project name there. `connect_idaifield()` will check if
#' the project actually exists and throw an error if it does not.
#'
#' @param serverip The IP address of the Field Client. If you are using
#' Field Desktop on the same machine, the default value is "127.0.0.1".
#' @param project The name of the project you want to work with.
#' If you do not supply this parameter, other functions will use the
#' project recorded in the connection object.
#' @param user (optional) The username for the connection.
#' This parameter is not currently needed.
#' @param pwd The password used to authenticate with the Field
#' Client (default is "password").
#' @param version The version number of the Field Client. By default,
#' the value is set to 3.
#' @param ping logical. Whether to test the connection on creation
#' (default is TRUE). If TRUE, connect_idaifield() also checks if the
#' project exists.
#'
#' @return `connect_idaifield()` returns an `idf_connection_settings`
#' object that contains the connection settings needed to connect to the
#' database of your iDAI.field / Field Desktop Client.
#' @export
#'
#' @seealso
#' \code{\link{idf_ping}}, \code{\link{idf_projects}}
#'
#' @references
#' Field Desktop Client: \url{https://github.com/dainst/idai-field}
#'
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(serverip = "127.0.0.1", user = "R", pwd = "hallo", project = "rtest")
#'
#' conn$status
#'
#' idf_ping(conn)
#' }
connect_idaifield <- function(serverip    = "127.0.0.1",
                              project     = NULL,
                              user        = "R",
                              pwd         = "password",
                              version     = 3,
                              ping        = TRUE) {

  serverip <- as.character(serverip)
  validip <- grepl("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", serverip)
  if (!validip || length(serverip) == 0) {
    stop("Please supply a valid IP-Adress, e.g. '127.0.0.1' if Field Desktop is running on the same machine as R.")
  }

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
      idf_check_for_project(conn)
    }
  }

  return(conn)
}

#' Check for the existence of a project in a Field Database (internal)
#'
#' This function checks if a given project exists in the Field Database.
#' If the project does not exist, it throws an error.
#'
#' @param conn The connection settings as returned
#' by \code{\link{connect_idaifield}}
#' @param project (optional) character. Name of the project-database to
#' check for. If not supplied, the function will use the project specified
#' in the connection settings.
#'
#'
#' @references
#' Field Desktop Client: \url{https://github.com/dainst/idai-field}
#'
#' @keywords internal
#' @return NULL
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' check_for_project(conn) # Will not return anything
#' }
idf_check_for_project <- function(conn, project = NULL) {
  if (is.null(project) && is.null(conn$project)) {
    stop("No project supplied to `check_for_project()`")
  } else {
    project <- ifelse(is.null(project), conn$project, project)
  }
  choices <- suppressMessages(idf_projects(conn))
  project_present <- project %in% choices
  if (!project_present) {
    stop(paste0("The requested project '", project, "' does not exist.\n",
                "Choose one of: ", paste(choices, collapse = ", ")))
  }
}



#' Create a client connection to a Field database (internal)
#'
#' This function creates a `crul::HttpClient` object for use in retrieving
#' all documents from or querying a Field database associated with a
#' specific project. This function is intended for internal use only.
#'
#' @param conn A connection object returned by \code{\link{connect_idaifield}}.
#' @param project character. Name of the project-database that should be loaded.
#'
#' @references
#' For more information about the crul package, see: \url{https://cran.r-project.org/package=crul}
#' Field Desktop Client: \url{https://github.com/dainst/idai-field}
#'
#' @seealso
#' \code{\link{connect_idaifield}} for information about connecting to Field
#' and `?crul::HttpClient` which this function uses.
#'
#' @return A `crul::HttpClient` object.
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
  if (is.null(project) & !is.null(conn$project)) {
    project <- conn$project
  }

  if (is.null(project)) {
    stop("Supply a project either here or in the connection settings (`connect_idaifield()`)!")
  } else {
    url <- paste0(conn$settings$base_url, "/", project)
  }

  include <- match.arg(include, c("all", "query"), several.ok = FALSE)

  if (is.na(conn$status) || !conn$status) {
    message(paste0("Status set to '", conn$status,
                   "'. Attempting to reach database..."))
    conn$status <- idf_ping(conn)
  }

  if (!conn$status) {
    stop("Could not reach database - check the connection settings.")
  } else {
    idf_check_for_project(conn, project)

    proj_conn <- crul::HttpClient$new(url = url,
                                      opts = conn$settings$auth,
                                      headers = conn$settings$headers)

    message <- response_to_list(proj_conn$get())
    message <- paste0("Connected to project '", message$db_name,
                      "' containing ", message$doc_count, " docs.")

    message(message)
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
#' This function checks if a connection to the Field Database
#' can be established. It returns a boolean value indicating if the
#' connection was successful or not.
#'
#' @param conn An object that contains the connection settings, as
#' returned by \code{\link{connect_idaifield}} or a `crul::HttpClient`.
#'
#' @return A boolean value indicating if the connection
#' was successful (TRUE) or not (FALSE).
#'
#' @export
#'
#' @seealso \code{\link{connect_idaifield}}, \code{\link{idf_projects}}
#'
#'
#' @references
#' Field Desktop Client: \url{https://github.com/dainst/idai-field}
#'
#'
#' @examples
#' \dontrun{
#' # Establish a connection to the Field Database
#' conn <- connect_idaifield(ping = FALSE)
#'
#' # Ping the Field Database
#' idf_ping(conn)
#' }
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
      if (grepl("refused", ping[1])) {
        warning("Either Field Desktop is not running, or the serverip in `connect_idaifield()` is incorrect.")
      } else {
        warning(paste0("Unexpected Error in `idf_ping()`:\n", ping[1]))
      }
      return(FALSE)
    } else if (grepl("Welcome", ping)) {
      # return true if connection works
      ping <- jsonlite::fromJSON(ping)
      message(paste(ping[[1]], "- Connection to Field Database can be established."))
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


