source("../load_testdata.R")

test_that("returns list", {
  expect_true(inherits(config, "idaifield_config"))
})

test_that("error when supplying wrong object", {
  expect_error(test <- get_configuration(NA))
})


skip_on_cran()
skip_if_no_field_desktop()
connection <- skip_if_no_connection()

test_that("returns NA if project does not exist", {
  connection$project <- "testasdasd"
  config <- suppressWarnings(get_configuration(connection))
  expect_equal(config, NA)
})

test_that("returns a list with the expected names at toplevel", {
  config <- get_configuration(connection)
  toplevel <- list(projectLanguages = list(), categories = list())
  expect_identical(names(config), names(toplevel))
})

test_that("returns a list with names category lists", {
  config <- get_configuration(connection)
  expect_true("Project" %in% names(config$categories))
})

