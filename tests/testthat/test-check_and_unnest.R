source(file = "../load_testdata.R")

test_that("check_and_unnest fails", {
  expect_error(check_and_unnest(list("börek", "mehr börek",
                                     "weniger börek",
                                     "genau richtig viel börek")))
  expect_error(check_and_unnest(rnorm(10)))
})

# this is stupid
test_that("does its job", {
  expect_identical(check_and_unnest(test_docs), test_resources)
})
