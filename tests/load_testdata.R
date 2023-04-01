library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- check_and_unnest(test_docs)

config <- attributes(test_docs)$config


skip_if_no_connection <- function() {
  connection <- suppressMessages(
    connect_idaifield(serverip = "127.0.0.1", project = "rtest",
                      pwd = "hallo", ping = FALSE)
    )

  ping <- try(idf_ping(connection))

  if (!inherits(ping, "try-error")) {
    connection$status <- idf_ping(connection)
    return(connection)
  }

  skip("Test skipped, needs DB-connection")
}
