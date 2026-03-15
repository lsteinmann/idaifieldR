test_that("returns a vector and works for nested and unnested", {
  expect_vector(idf_show_categories(test_docs))
  res <- maybe_unnest_docs(test_docs)
  expect_vector(idf_show_categories(res))
})
