source(file = "../load_testdata.R")

test_that("checking works for docs-lists", {
  check <- check_if_idaifield(test_docs)
  expect_true(check["idaifield_docs"])
})


test_that("checking works for docs-lists", {
  check <- check_if_idaifield(test_docs)
  expect_false(check["idaifield_resources"])
})

test_that("checking works for resource-lists", {
  check <- check_if_idaifield(test_resources)
  expect_true(check["idaifield_resources"])
})

test_that("checking works for resource-lists", {
  check <- check_if_idaifield(unnest_docs(test_docs))
  expect_true(check["idaifield_resources"])
})

test_that("checking works for simplified lists", {
  check <- check_if_idaifield(simplify_idaifield(test_docs))
  expect_true(check["idaifield_simple"])
})
