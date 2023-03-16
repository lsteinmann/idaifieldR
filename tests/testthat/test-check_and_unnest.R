source(file = "../load_testdata.R")

test_that("check_and_unnest fails", {
  expect_warning(check_and_unnest(list("börek", "mehr börek",
                                     "weniger börek",
                                     "genau richtig viel börek")))
  expect_warning(check_and_unnest(rnorm(10)))
})

# this is stupid
test_that("unnests to resource level", {
  expect_identical(check_and_unnest(test_docs), test_resources)
})

test_simple <- simplify_idaifield(test_resources)

# this is stupid
test_that("does not change simplified list", {
  expect_identical(check_and_unnest(test_simple), test_simple)
})

test_that("does not change resource list", {
  expect_identical(check_and_unnest(test_resources), test_resources)
})

test_that("keeps attributes", {
  test <- check_and_unnest(test_docs)
  expect_identical(attr(test_docs, "config"), attr(test, "config"))
  expect_identical(attr(test_docs, "connection"), attr(test, "connection"))
  expect_identical(attr(test_docs, "projectname"), attr(test, "projectname"))
})

