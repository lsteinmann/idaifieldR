source(file = "../load_testdata.R")

test_that("checking works for docs-lists", {
  docs <- list(1, 2, 3)
  class(docs) <- "idaifield_docs"
  check <- check_if_idaifield(docs)
  expect_true(check["idaifield_docs"])
})

test_that("checking works for resource-lists", {
  resources <- list(1, 2, 3)
  class(resources) <- "idaifield_resources"
  check <- check_if_idaifield(resources)
  expect_true(check["idaifield_resources"])
})

test_that("checking works for simplified lists", {
  simple <- list(1, 2, 3)
  class(simple) <- "idaifield_simple"
  check <- check_if_idaifield(simple)
  expect_true(check["idaifield_simple"])
})
