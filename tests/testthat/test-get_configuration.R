source("../load_testdata.R")

test_that("returns list", {
  expect_true(is.list(config))
})

test_that("error when supplying wrong object", {
  expect_error(test <- get_configuration(NA, projectname = NULL))
})


skip_on_cran()

connection <- skip_if_no_connection()

test_that("returns NA if project does not exist", {
  connection$project <- "testasdasd"
  config <- suppressWarnings(get_configuration(connection))
  expect_equal(config, NA)
})


test_that("error for missing config not working, returns NA", {
  connection$project <- "test"
  expect_warning(test <- get_configuration(connection),
                 "no configuration")
  expect_identical(test, NA)
})

test_that("returns a list that is actually the configuration", {
  config <- get_configuration(connection)
  expect_true(config$identifier == "Configuration")
})
