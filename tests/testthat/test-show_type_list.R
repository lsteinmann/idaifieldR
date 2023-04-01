source(file = "../load_testdata.R")



test_that("returns a vector and works for nested and unnested", {
  expect_vector(show_categories(test_docs))
  expect_vector(show_categories(test_resources))
})


test_that("same for nested and unnested", {
  expect_equal(show_categories(test_docs),
               show_categories(test_resources))
})
