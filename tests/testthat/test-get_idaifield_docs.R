skip_on_cran()

serverip <- "192.168.2.21"

idaifield_connection <- sofa::Cushion$new(host = serverip,
                                          transport = "http",
                                          port = 3000,
                                          user = "R",
                                          pwd = "hallo")

check_db_availability <- function() {
  connection_exists <- tryCatch({
    sofa::ping(idaifield_connection)
  },
  error = function(cond) {
    return(NA)
  })

  if (length(connection_exists) > 1) {
    connection_exists <- TRUE
  } else {
    connection_exists <- FALSE
  }
}

if (!check_db_availability()) {
  skip("Test skipped, needs DB-connection")
}



test_docs <- get_idaifield_docs(serverip = serverip,
                                projectname = "rtest",
                                user = "R",
                                pwd = "hallo",
                                simplified = FALSE)

test_resources <- get_idaifield_docs(serverip = serverip,
                                     projectname = "rtest",
                                     user = "R",
                                     pwd = "hallo",
                                     simplified = TRUE)

test_that("returns docs-lists", {
  check <- check_if_idaifield(test_docs)
  expect_true(check["idaifield_docs"], TRUE)
})

test_that("returns resource-lists", {
  check <- check_if_idaifield(test_resources)
  expect_true(check["idaifield_resources"], TRUE)
})
