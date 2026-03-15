test_that("raw has connection as attribute", {
  conn <- suppressWarnings(connect_idaifield(pwd = "wrongpwd", project = "rtest", ping = FALSE))
  expect_error(suppressWarnings(get_idaifield_docs(conn)))
})



test_that("items are named", {
  rnr <- sample(seq_along(test_docs), 1)
  expect_identical(names(test_docs)[rnr],
                   test_docs[[rnr]]$doc$resource$identifier)
})



test_that("raw has connection settings as attribute", {
  test <- attr(test_docs, "connection")
  expect_true("idf_connection_settings" %in% class(test))
})



skip_on_cran()
connection <- skip_if_no_couchdb()


test_that("works without config in project", {
  conn <- connection
  conn$project <- "test"
  test_docs <- get_idaifield_docs(connection = conn)
  expect_true(inherits(test_docs, "idaifield_docs"))
})

test_docs_raw <- get_idaifield_docs(connection = connection,
                                    raw = TRUE)


test_that("class is assignes", {
  expect_true(inherits(test_docs_raw, "idaifield_docs"))
})

test_that("returns resource-lists", {
  test_resources <- get_idaifield_docs(connection = connection,
                                       raw = FALSE)
  expect_true(inherits(test_resources, "idaifield_resources"))
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

