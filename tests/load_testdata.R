library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- check_and_unnest(test_docs)

config <- readRDS(system.file("testdata", "rtest_config.RDS",
                              package = "idaifieldR"))


skip_if_no_connection <- function() {
  connection <- suppressWarnings(connect_idaifield(serverip = "127.0.0.1",
                                                   user = "R", pwd = "hallo"))

  tryCatch({
    sofa::ping(connection)
  },
  error = function(cond) {
    skip("Test skipped, needs DB-connection")
  })

  return(connection)
}
