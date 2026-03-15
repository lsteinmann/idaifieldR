#' Skip the Tests if CouchDB/PouchDB can't be reached.
skip_if_no_couchdb <- function() {
  connection <- suppressMessages(
    connect_idaifield(serverip = "127.0.0.1", project = "rtest",
                      pwd = "hallo", ping = FALSE)
  )

  ping <- suppressWarnings(suppressMessages(idf_ping(connection)))

  if (ping) {
    return(connection)
  } else {
    skip("Test skipped, needs DB-connection")
  }
}

#' Skip the Tests if Field Desktop can't be reached.
skip_if_no_field_desktop <- function(pwd = "hallo") {
  headers <- list(`Content-Type` = "application/json",
                  Accept = "application/json")
  client <- crul::HttpClient$new(url = "http://localhost:3000/info",
                                 opts = crul::auth(user = "R", pwd = pwd),
                                 headers = headers)
  response <- try(client$get(), silent = TRUE)
  if (inherits(response, "try-error")) {
    skip("Test skipped, Field Desktop not available on localhost.")
  } else {
    if (!response$success()) {
      skip("Test skipped, Field Desktop not available on localhost.")
    }
  }
}

