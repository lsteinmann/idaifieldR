source(file = "../load_testdata.R")

test_that("checking works for docs-lists", {
  check <- suppressMessages(check_if_idaifield(test_resource))
  expect_identical(unname(check[1, "idaifield_docs"]), TRUE)
})



test_that("checking works for resource-lists", {
  check <- suppressMessages(check_if_idaifield(unnested_test_resource))
  expect_identical(unname(check[1, "idaifield_resource"]), TRUE)
})

test_that("checking works for resource-lists", {
  check <- suppressMessages(check_if_idaifield(unnest_resource(test_resource)))
  expect_identical(unname(check[1, "idaifield_resource"]), TRUE)
})
