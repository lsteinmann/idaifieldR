source(file = "../load_testdata.R")

uidlist <- make_index(test_docs)

test_that("returns same amount of elements", {
  expect_equal(length(gather_trenches(uidlist)), nrow(uidlist))
})

test_that("returns character vector", {
  expect_true(is.character(gather_trenches(uidlist)))
})
