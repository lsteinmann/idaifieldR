library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- maybe_unnest_docs(test_docs)

test_simple <- simplify_idaifield(test_resources)

config <- readRDS(system.file("testdata", "idaifield_test_config.RDS",
                              package = "idaifieldR"))


skip_if_no_connection <- function() {
  connection <- suppressMessages(
    connect_idaifield(serverip = "127.0.0.1", project = "rtest",
                      pwd = "hallo", ping = FALSE)
    )

  ping <- suppressWarnings(suppressMessages(idf_ping(connection)))

  if (ping) {
    connection$status <- idf_ping(connection)
    return(connection)
  } else {
    skip("Test skipped, needs DB-connection")
  }
}

skip_if_no_field_desktop <- function(pwd = "hallo") {
  headers <- list(`Content-Type` = "application/json",
                  Accept = "application/json")
  client <- crul::HttpClient$new(url = "http://localhost:3000/info",
                                 opts = crul::auth(user = "R", pwd = pwd),
                                 headers = headers)
  response <- client$get()
  if (!response$success()) {
    skip("Test skipped, Field Desktop not available on localhost.")
  }
}

