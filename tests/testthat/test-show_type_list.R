source(file = "../load_testdata.R")



test_that("returns a vector and works for nested and unnested", {
  expect_vector(show_type_list(test_resource))
  expect_vector(show_type_list(unnested_test_resource))
})


test_that("same for nested and unnested", {
  expect_equal(show_type_list(test_resource),
               show_type_list(unnested_test_resource))
})
