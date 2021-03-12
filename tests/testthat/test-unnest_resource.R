source(file = "../load_testdata.R")

test_that("unnest_resource returns a list", {
  expect_identical(class(unnest_resource(test_docs)), "idaifield_resources")
})

item <- sample(seq_along(test_docs), 1)

test_that("unnested resource has same id", {
  expect_identical(unnest_resource(test_docs)[[item]]$id,
                   test_docs[[item]]$id)
  expect_identical(unnest_resource(test_docs)[[item]]$id,
                   test_docs[[item]]$doc$resource$id)
})

test_that("unnest_resource does not process non-list", {
  expect_error(unnest_resource(1), regexp = "not.*.processed")
})

test_that("unnest_resource messages about already unnested res", {
  expect_message(unnest_resource(test_resources), regexp = "unnested")
  expect_identical(unnest_resource(test_resources), test_resources)
})

testlist <- list("this", "is", "not", list("what", "I", "want"))

test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(testlist), regexp = "not.*.processed")
})

test_that("relation naming works", {
  greps <- grepl("relations", names(test_resources[[item]]))
  expect_true(any(greps))
})

list <- list("börek", "kaffee", list(rep(1, 2, 3)))
test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(list), regexp = "cannot")
})
