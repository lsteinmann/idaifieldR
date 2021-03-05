source(file = "../load_testdata.R")

test_that("check_and_unnest fails", {
  expect_error(check_and_unnest(list("börek", "mehr börek", "weniger börek", "genau richtig viel börek")))
  expect_error(check_and_unnest(rnorm(10)))
})

test_that("does its job", {
  expect_identical(check_and_unnest(test_resource), unnested_test_resource)
})
