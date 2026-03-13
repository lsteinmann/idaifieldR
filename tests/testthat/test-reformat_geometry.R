test_that("handles empty param", {
  expect_true(is.na(maybe_to_json(NULL)))
})
