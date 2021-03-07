source(file = "../load_testdata.R")

test_that("checking works for docs-lists", {
  check <- check_if_idaifield(test_resource)
  expect_true(check["idaifield_docs"])
})

test_that("checking works for docs-lists", {
  check <- check_if_idaifield(test_resource)
  expect_false(check["idaifield_resources"])
})

test_that("checking works for resource-lists", {
  check <- check_if_idaifield(unnested_test_resource)
  expect_true(check["idaifield_resources"])
})

test_that("checking works for resource-lists", {
  check <- check_if_idaifield(unnest_resource(test_resource))
  expect_true(check["idaifield_resources"])
})

expect_true
