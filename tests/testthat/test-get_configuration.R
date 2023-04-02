

test_that("returns list", {
  expect_true(is.list(config))
})

test_that("returns a matrix", {
  fields <- get_field_inputtypes(config, inputType = "checkboxes")
  expect_true(is.matrix(fields))
})

test_that("returns correct inputtype", {
  fields <- get_field_inputtypes(config, inputType = "checkboxes")
  expect_true(fields[1, 3] == "checkboxes")
})

test_that("works for boolean", {
  fields <- get_field_inputtypes(config, inputType = "boolean")
  expect_true(fields[1, 3] == "boolean")
})

test_that("returns all if not existing", {
  fields <- get_field_inputtypes(config, inputType = "kuchen")
  expect_gt(length(unique(fields[, 3])), 1)
})

test_that("returns all if not existing", {
  fields <- get_field_inputtypes(config, inputType = 3)
  expect_gt(length(unique(fields[, 3])), 1)
})

empty_config <- readRDS(system.file("testdata", "empty_config.RDS",
                                    package = "idaifieldR"))

test_that("warning for empty config", {
  expect_warning(get_field_inputtypes(empty_config))
})


test_that("empty matrix for empty config", {
  expect_equal(nrow(suppressWarnings(get_field_inputtypes(empty_config))), 0)
})


test_that("error when supplying wrong object", {
  expect_error(test <- get_configuration(NA, projectname = "testproj"))
})


skip_on_cran()

connection <- skip_if_no_connection()

test_that("returns NA for missing config", {
  config <- suppressWarnings(get_configuration(connection,
                                               projectname = "test"))
  expect_equal(config, NA)
})


test_that("error for missing config not working, returns NA", {
  expect_warning(test <- get_configuration(connection,
                                           projectname = "test"),
                 "no configuration")
  expect_identical(test, NA)
})

test_that("returns a list that is actually the configuration", {
  config <- get_configuration(connection, projectname = "rtest")
  expect_true(config$identifier == "Configuration")
})
