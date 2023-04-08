library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- check_and_unnest(test_docs)

test_simple <- simplify_idaifield(test_resources)

config <- readRDS(system.file("testdata", "idaifield_test_config.RDS",
                              package = "idaifieldR"))


skip_if_no_connection <- function() {
  connection <- suppressMessages(
    connect_idaifield(serverip = "127.0.0.1", project = "rtest",
                      pwd = "hallo", ping = FALSE)
    )

  ping <- suppressWarnings(idf_ping(connection))

  if (ping) {
    connection$status <- idf_ping(connection)
    return(connection)
  } else {
    skip("Test skipped, needs DB-connection")
  }
}
