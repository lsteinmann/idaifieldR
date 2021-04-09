source(file = "../load_testdata.R")



test_that("returns a vector and works for nested and unnested", {
  expect_vector(show_type_list(test_docs))
  expect_vector(show_type_list(test_resources))
})


test_that("same for nested and unnested", {
  expect_equal(show_type_list(test_docs),
               show_type_list(test_resources))
})
