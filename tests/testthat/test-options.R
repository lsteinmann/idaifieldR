test_that("options exist", {
  options <- getOption("idaifield_types")
  expect_true(is.list(options))
})

test_that("lists are there and strict is shorter", {
  options <- getOption("idaifield_types")
  expect_gt(length(options$layers), length(options$layers_strict))
})
