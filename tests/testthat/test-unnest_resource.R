source(file = "../load_testdata.R")

test_that("unnest_resource returns a list", {
  expect_identical(class(unnest_resource(test_resource)), "idaifield_resource")
})

item <- sample(seq_along(test_resource), 1)

test_that("unnested resource has same id", {
  expect_identical(unnest_resource(test_resource)[[item]]$id,
                   test_resource[[item]]$id)
  expect_identical(unnest_resource(test_resource)[[item]]$id,
                   test_resource[[item]]$doc$resource$id)
})

test_that("unnest_resource does not process non-list", {
  expect_error(unnest_resource(1), regexp = "not.*.processed")
})

testlist <- list("this", "is", "not", list("what", "I", "want"))

test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(testlist), regexp = "not.*.processed")
})

test_that("relation naming works", {
  greps <- grepl("relations", names(unnested_test_resource[[item]]))
  expect_true(any(greps))
})

test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(unnested_test_resource), regexp = "unnested")
})
