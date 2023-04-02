source(file = "../load_testdata.R")



test_that("renames type to category", {
  cat_in_names <- lapply(type_to_category(test_docs), function (x) {
    "category" %in% names(x$doc$resource)
  })
  cat_in_names <- unlist(cat_in_names)
  expect_true(all(cat_in_names))
})


conn <- skip_if_no_connection()


test_that("renames type to category", {
  cat_in_names <- lapply(type_to_category(idf_query(conn)), function (x) {
    "category" %in% names(x$doc$resource)
  })
  cat_in_names <- unlist(cat_in_names)
  expect_true(all(cat_in_names))
})
