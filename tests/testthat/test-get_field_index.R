source(file = "../load_testdata.R")

conn <- skip_if_no_connection()

test_that("gets df from connection", {
  expect_true(is.data.frame(get_field_index(conn)))
})

test_that("returns shortDescription when verbose", {
  index <- get_field_index(conn, verbose = TRUE)
  expect_true("shortDescription" %in% colnames(index))
})

test_that("returns liesWithinLayer when find_layers", {
  index <- get_field_index(conn, find_layers = TRUE)
  expect_true("liesWithinLayer" %in% colnames(index))
})

test_that("returns Place when gather_trenches", {
  index <- get_field_index(conn, gather_trenches = TRUE)
  expect_true("Place" %in% colnames(index))
})
