source(file = "../load_testdata.R")

test_matrix <- idaifield_as_matrix(test_resource)

test_that("returns a matrix", {
  expect_equal(class(test_matrix)[1], "matrix")
})

test_that("length matches", {
  expect_identical(nrow(test_matrix),
                   length(test_resource))
})
