#' Connect to an iDAI.field / Field Desktop Client
#'
#' @description This function establishes a connection to the database of your
#' [iDAI.field / Field Desktop Client](https://github.com/dainst/idai-field),
#' and returns a connection object containing the necessary information for
#' other functions to access the database, such as [get_idaifield_docs()],
#' [idf_query()], [idf_index_query()], or [idf_json_query()].
#'
#' @details By default, if you are using Field Desktop on the same machine,
#' you should not need to specify the `serverip` argument, as it defaults to
#' "localhost". If you want to access a client on the same network that is
#' not running on the same computer as R, you can supply the local IP
#' (without the port (':3000')).
#' The `pwd` argument needs to be set to the password that
#' is set in your Field Desktop Client under *Tools/Werkzeuge* >
#' *Settings/Einstellungen*: 'Your password'/'Eigenes Passwort'.
#' `project` has to be set to the identifier of the project database you
#' will query.
#'
#' @param serverip The IP address of the Field Client, or "localhost". Leave
#' the default if you are using Field Desktop on the same computer.
#' @param project (*required*) The name of the project you want to work with.
#' For a list of available projects, see [idf_projects()].
#' @param pwd (*required*) The password used to authenticate with the Field
#' Client (default is "password").
#' @param ping Should the connection be pinges on creation? Defaults to TRUE.
#'
#' @returns [connect_idaifield()] returns an `idf_connection_settings`
#' object that is used by other functions in this package to retrieve data
#' from the
#' [iDAI.field / Field Desktop Client](https://github.com/dainst/idai-field).
#' @export
#'
#' @seealso
#' * Ping the connection with [idf_ping()]
#' * Get a list of projects in the database with [idf_projects()]
#'
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(
#'   serverip = "localhost",
#'   pwd = "hallo",
#'   project = "rtest"
#' )
#'
#' conn$status
#'
#' idf_ping(conn)
#' }
connect_idaifield <- function(serverip    = "localhost",
                              project     = NULL,
                              pwd         = "password",
                              ping        = TRUE) {

  serverip <- as.character(serverip)
  validip <- grepl("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$|^localhost$", serverip)
  if (!validip || length(serverip) == 0) {
    stop("Please supply a valid IP-Adress.")
  }

  if (is.null(project)) {
    stop("Required parameter 'project' missing in connect_idaifield()")
  }

  headers <- list(`Content-Type` = "application/json",
                  Accept = "application/json")
  auth <- crul::auth(user = "R", pwd = pwd)
  base_url <- paste0("http://", serverip, ":3001")

  settings <- list(headers = headers,
                   base_url = base_url,
                   auth = auth)

  params <- list(
    serverip    = serverip,
    project     = project,
    pwd         = pwd,
    ping        = ping
  )

  status <- NA
  conn <- list(status = status, project = project, settings = settings, params = params)
  conn <- structure(conn, class = "idf_connection_settings")

  if (ping) {
    conn$status <- idf_ping(conn)
    if (conn$status) {
      idf_check_for_project(conn)
    }
  }

  return(conn)
}



#' Check for the Existence of a Project in a Field Database (internal)
#'
#' This function checks if a given project exists in the Field Database.
#' If the project does not exist, it throws an error.
#'
#' @param conn The connection settings as returned
#' by [connect_idaifield()]
#'
#'
#' @keywords internal
#' @returns NULL
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(pwd = "hallo", project = "rtest")
#' check_for_project(conn) # Will not return anything
#' }
idf_check_for_project <- function(conn) {
  stop_if_not_idf_connection_settings(conn)
  choices <- suppressMessages(idf_projects(conn))
  if (!conn$project %in% choices) {
    stop(paste0("The requested project '", conn$project, "' does not exist.\n",
                "Choose one of: ", paste(choices, collapse = ", ")))
  }
}



#' Create a Connection Client to a Field database (internal)
#'
#' This function creates a [crul::HttpClient]object for use in retrieving
#' all documents from or querying a Field database associated with a
#' specific project. This function is intended for internal use only.
#'
#' @param conn A connection object returned by [connect_idaifield()].
#' @param project (deprecated) character. Name of the project-database that should be loaded.
#' @param include Arguments: "all", "query", "changes" . Should the client
#' use "*_all_docs*", "*_find*" or "*_changes*" as paths.
#'
#'
#' * [crul on CRAN](https://cran.r-project.org/package=crul)
#' * [CouchDB API](https://docs.couchdb.org/en/stable/api/database/)
#'
#'
#'
#' @seealso
#' [connect_idaifield()] for information about connecting to Field
#' and [crul::HttpClient()] which this function uses.
#'
#' @returns A [crul::HttpClient()] object.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   connection <- connect_idaifield(pwd = "hallo", project = "rtest")
#'   client <- proj_idf_client(conn = connection)
#' }
proj_idf_client <- function(conn, include = "all") {
  stop_if_not_idf_connection_settings(conn)

  url <- paste0(conn$settings$base_url, "/", conn$project)

  include <- match.arg(include, c("all", "query", "changes"), several.ok = FALSE)

  if (is.na(conn$status) || !conn$status) {
    message(paste0("Status set to '", conn$status,
                   "'. Attempting to reach database..."))
    conn$status <- idf_ping(conn)
  }

  if (!conn$status) {
    stop("Could not reach database - check the connection settings.")
  } else {
    idf_check_for_project(conn)

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
  } else if (include == "changes") {
    url <- paste0(url, "/_changes")
  }

  proj_conn <- crul::HttpClient$new(url = url,
                                    opts = conn$settings$auth,
                                    headers = conn$settings$headers)

  return(proj_conn)
}

#' @title Ping the Field-Database
#'
#' @description
#' This function checks if a connection to the Field Database
#' can be established. It returns a boolean value indicating if the
#' connection was successful or not. Warnings are used to indicate why
#' the connection failed, if so.
#'
#' @param conn An object that contains the connection settings, as
#' returned by [connect_idaifield()].
#'
#' @returns A boolean value indicating if the connection
#' was successful (TRUE) or not (FALSE).
#'
#' @export
#'
#' @seealso
#' * Produce a Connection-Settings list with: [connect_idaifield()]
#' * Find all projects in the database with: [idf_projects()]
#'
#'
#'
#'
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
    client <- crul::HttpClient$new(url = conn$settings$base_url,
                                   opts = conn$settings$auth,
                                   headers = conn$settings$headers)
  } else {
    # return FALSE if passed object was not a connection
    warning("Supply an 'idf_connection_settings'-object as returned by `connect_idaifield()`.")
    return(FALSE)
  }
  if (inherits(client, "HttpClient")) {
    ping <- try(client$get()$parse("UTF-8"), silent = TRUE)
    if(inherits(ping, "try-error")) {
      # throw error when curl "Could not resolve host"
      if (grepl("refused", ping[1]) | grepl("Couldn't connect", ping[1])) {
        warning("Either Field Desktop is not running, or the serverip in `connect_idaifield()` is incorrect.")
      } else {
        warning(paste0("Unexpected Error in `idf_ping()`:\n", ping[1]))
      }
      return(FALSE)
    } else if (grepl("Welcome", ping)) {
      # return true if connection works
      ping <- jsonlite::fromJSON(ping)
      return(TRUE)
    } else {
      # return FALSE if connection does not work for expected reasons
      ping <- jsonlite::fromJSON(ping)
      ping <- paste0(unlist(ping, use.names = FALSE), collapse = ": ")
      warning(ping)
      return(FALSE)
    }
  }
}


#' Add limit to JSON query
#'
#' This is a helper function that adds a limit of the max db docs to a query.
#' It is not great.
#'
#' @param conn A connection object returned by [connect_idaifield()].
#' @param query A MongoDB JSON-query as used in this package.
#'
#' @returns A query with limit added for PouchDB
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' conn <- connect_idaifield(project = "test", pwd = "hallo")
#' fields <- c("resource.category", "resource.identifier")
#' query <- paste0('{ "selector": { "$not": { "resource.id": "" } },
#'    "fields": [', paste0('"', fields, '"', collapse = ", "), '] }')
#' add_limit_to_query(query, conn)
#' }
add_limit_to_query <- function(query, conn) {
  stop_if_not_idf_connection_settings(conn)
  if(!jsonlite::validate(query)) {
    stop("Could not validate JSON structure of query before adding limit.")
  }
  conn$settings$limit <- NA
  if (idf_ping(conn)) {
    client <- crul::HttpClient$new(url = paste0(conn$settings$base_url, "/", conn$project),
                                   opts = conn$settings$auth,
                                   headers = conn$settings$headers)
    response <- response_to_list(client$get())
    limit <- response$doc_count
  } else {
    stop()
  }

  limit <- paste0(', "limit": ', limit, ' }')
  new_query <- gsub("}$", limit, query)

  if(!jsonlite::validate(new_query)) {
    stop("Could not validate JSON structure of query after adding limit.")
  }
  return(new_query)
}

