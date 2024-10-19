

test_that("raw has connection as attribute", {
  conn <- suppressWarnings(connect_idaifield(pwd = "wrongpwd", project = "rtest", ping = FALSE))
  expect_error(suppressWarnings(get_idaifield_docs(conn)))
})

source(file = "../load_testdata.R")

test_that("items are named", {
  rnr <- sample(seq_along(test_docs), 1)
  expect_identical(names(test_docs)[rnr],
                   test_docs[[rnr]]$doc$resource$identifier)
})



test_that("raw has connection settings as attribute", {
  test <- attr(test_docs, "connection")
  expect_true("idf_connection_settings" %in% class(test))
})

test_that("resources has connection as attribute", {
  test <- attr(test_resources, "connection")
  expect_true("idf_connection_settings" %in% class(test))
})


skip_on_cran()
connection <- skip_if_no_connection()


test_that("works without config in project", {
  conn <- connection
  conn$project <- "test"
  test_docs <- get_idaifield_docs(connection = conn)
  check <- check_if_idaifield(test_docs)
  expect_true(check["idaifield_docs"], TRUE)
})

test_docs_raw <- get_idaifield_docs(connection = connection,
                                    raw = TRUE)


test_that("returns docs-lists", {
  check <- check_if_idaifield(test_docs_raw)
  expect_true(check["idaifield_docs"], TRUE)
})

test_that("returns resource-lists", {
  test_resources <- get_idaifield_docs(connection = connection,
                                       raw = FALSE)
  check <- check_if_idaifield(test_resources)
  expect_true(check["idaifield_resources"], TRUE)
})


test_that("returns simple-lists", {
  check <- check_if_idaifield(test_simple)
  expect_true(check["idaifield_simple"], TRUE)
})

test_that("returns json", {
  output <- get_idaifield_docs(connection = connection,
                               json = TRUE)
  expect_true(jsonlite::validate(output))
})

test_that("attaches working connection as attribute", {
  test_conn <- attr(test_docs_raw, "connection")
  test_conn <- idf_ping(test_conn)
  expect_true(test_conn)
})

