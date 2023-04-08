source(file = "../load_testdata.R")



test_that("returns a vector and works for nested and unnested", {
  expect_vector(idf_show_categories(test_docs))
  expect_vector(idf_show_categories(test_resources))
})


test_that("same for nested and unnested", {
  expect_equal(idf_show_categories(test_docs),
               idf_show_categories(test_resources))
})
