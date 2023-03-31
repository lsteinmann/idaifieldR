test_that("negative value for bce", {
  list <- list(inputYear = 100, inputType = "bce")
  expect_equal(bce_ce(list), -100)
})

test_that("positive value for ce", {
  list <- list(inputYear = 100, inputType = "ce")
  expect_equal(bce_ce(list), 100)
})

test_that("calculates bp correctly", {
  list <- list(inputYear = 1950, inputType = "bp")
  expect_equal(bce_ce(list), 0)
})

test_that("error for wrong inputtype", {
  list <- list(inputYear = 1950, inputType = "no")
  expect_error(bce_ce(list))
})

test_that("NA for no list", {
  list <- "zonk"
  expect_identical(bce_ce(list), NA)
})

