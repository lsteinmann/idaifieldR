source(file = "../load_testdata.R")

test_matrix <- idaifield_as_matrix(test_docs)

test_that("returns a matrix", {
  expect_equal(class(test_matrix)[1], "matrix")
})

test_that("length matches", {
  expect_identical(nrow(test_matrix),
                   length(test_docs))
})

test_that("has category column", {
  expect_identical(length(test_docs),
                   length(test_matrix[,"category"]))
})

test_that("has no type column", {
  cols <- colnames(test_matrix)
  expect_false("type" %in% cols)
})
