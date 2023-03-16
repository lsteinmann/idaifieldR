test_that("raw has connection as attribute", {
  conn <- suppressWarnings(connect_idaifield(pwd = "wrongpwd"))
  expect_error(get_idaifield_docs(conn))
})

source(file = "../load_testdata.R")

test_that("items are named", {
  rnr <- sample(1:length(test_docs), 1)
  expect_identical(names(test_docs)[rnr],
                   test_docs[[rnr]]$doc$resource$identifier)
})





skip_on_cran()
connection <- skip_if_no_connection()


test_docs_raw <- get_idaifield_docs(projectname = "rtest",
                                connection = connection,
                                raw = TRUE)

test_resources <- get_idaifield_docs(projectname = "rtest",
                                connection = connection,
                                raw = FALSE)

test_simple <- simplify_idaifield(test_resources)


test_that("raw has connection as attribute", {
  test <- attr(test_docs_raw, "connection")
  expect_true("Cushion" %in% class(test))
})

test_that("resources has connection as attribute", {
  test <- attr(test_resources, "connection")
  expect_true("Cushion" %in% class(test))
})

test_that("simple has connection as attribute", {
  test <- attr(test_simple, "connection")
  expect_true("Cushion" %in% class(test))
})


test_that("raw has config as attribute", {
  test <- attr(test_docs_raw, "config")
  expect_identical(test$identifier, "Configuration")
})

test_that("resources has config as attribute", {
  test <- attr(test_resources, "config")
  expect_identical(test$identifier, "Configuration")
})

test_that("simple has config as attribute", {
  test <- attr(test_simple, "config")
  expect_identical(test$identifier, "Configuration")
})


test_that("returns docs-lists", {
  check <- check_if_idaifield(test_docs_raw)
  expect_true(check["idaifield_docs"], TRUE)
})

test_that("returns resource-lists", {
  check <- check_if_idaifield(test_resources)
  expect_true(check["idaifield_resources"], TRUE)
})


test_that("returns simple-lists", {
  check <- check_if_idaifield(test_simple)
  expect_true(check["idaifield_simple"], TRUE)
})

test_that("returns json", {
  output <- get_idaifield_docs(projectname = "rtest",
                               connection = connection,
                               json = TRUE)
  expect_true(jsonlite::validate(output))
})

test_that("attaches working connection as attribute", {
  test_conn <- attr(test_docs_raw, "connection")
  pinglist <- sofa::ping(test_conn)
  expect_true(is.list(pinglist))
})
