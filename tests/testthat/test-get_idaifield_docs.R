skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({sofa::ping(connection)},
         error = function(cond) {
           skip("Test skipped, needs DB-connection")
         })


test_that("works with 2", {
  conn2 <- connect_idaifield(serverip = "127.0.0.1",
                             user = "R", pwd = "hallo",
                             version = 2)
  expect_equal(conn2$port, 3000)
})

test_that("works with 3", {
  conn2 <- connect_idaifield(serverip = "127.0.0.1",
                             user = "R", pwd = "hallo",
                             version = 3)
  expect_equal(conn2$port, 3001)
})

test_that("works with '3'", {
  conn2 <- connect_idaifield(serverip = "127.0.0.1",
                             user = "R", pwd = "hallo",
                             version = "3")
  expect_equal(conn2$port, 3001)
})

test_that("error when using character", {
  expect_error(connect_idaifield(serverip = "127.0.0.1",
                                 user = "R", pwd = "hallo",
                                 version = "kuchen"))
})


test_docs <- get_idaifield_docs(projectname = "rtest",
                                connection = connection,
                                simplified = FALSE)

test_resources <- get_idaifield_docs(projectname = "rtest",
                                     connection = connection,
                                     simplified = TRUE)
test_that("has connection as attribute", {
  test <- attr(test_docs, "connection")
  expect_true("Cushion" %in% class(test))
})

test_that("has connection as attribute", {
  test <- attr(test_resources, "connection")
  expect_true("Cushion" %in% class(test))
})


test_that("returns docs-lists", {
  check <- check_if_idaifield(test_docs)
  expect_true(check["idaifield_docs"], TRUE)
})

test_that("returns resource-lists", {
  check <- check_if_idaifield(test_resources)
  expect_true(check["idaifield_resources"], TRUE)
})

test_that("returns json", {
  output <- get_idaifield_docs(projectname = "rtest",
                               connection = connection,
                               json = TRUE)
  expect_true(jsonlite::validate(output))
})

test_that("attaches connection as attribute", {
  test_conn <- attr(test_docs, "connection")
  pinglist <- sofa::ping(test_conn)
  expect_true(is.list(pinglist))
})


