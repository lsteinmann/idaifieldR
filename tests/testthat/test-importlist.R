

test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS", package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)


test_that("returns a vector and works for nested and unnested", {
  expect_vector(show_type_list(test_resource))
  expect_vector(show_type_list(unnested_test_resource))
})


test_that("same for nested and unnested", {
  expect_equal(show_type_list(test_resource), show_type_list(unnested_test_resource))
})


