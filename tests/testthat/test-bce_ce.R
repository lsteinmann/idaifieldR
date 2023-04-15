test_that("Converts BCE year to negative number", {
  input_list <- list(inputYear = 100, inputType = "bce")
  expected_output <- -100
  expect_equal(bce_ce(input_list), expected_output)
})

test_that("Converts CE year to positive number", {
  input_list <- list(inputYear = 100, inputType = "ce")
  expected_output <- 100
  expect_equal(bce_ce(input_list), expected_output)
})

test_that("Converts BP year to BCE year correctly", {
  input_list <- list(inputYear = 100, inputType = "bp")
  expected_output <- 1850
  expect_equal(bce_ce(input_list), expected_output)
})

test_that("Handles inputType error correctly", {
  input_list <- list(inputYear = 1950, inputType = "no")
  expect_error(bce_ce(input_list), "None of BCE/CE/BP given.")
})

test_that("Handles empty input list correctly", {
  input_list <- list()
  expect_error(bce_ce(input_list))
})

test_that("Handles non-list input correctly", {
  input_list <- "not a list"
  expect_true(is.na(suppressWarnings(bce_ce(input_list))))
})

test_that("Handles non-numeric inputYear correctly", {
  input_list <- list(inputYear = "not a number", inputType = "ce")
  expect_warning(bce_ce(input_list))
  expect_true(is.na(suppressWarnings(bce_ce(input_list))))
})
