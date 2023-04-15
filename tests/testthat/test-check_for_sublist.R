list <- list(1, 2, 3, 4)

test_that("check_for_sublist can process a list", {
  expect_false(check_for_sublist(list))
})

list <- list(list, 1, 2, 3)

test_that("check_for_sublist identifies sublists", {
  expect_true(check_for_sublist(list))
})

list <- list(list, "börek")

test_that("check_for_sublist identifies sublists", {
  expect_true(check_for_sublist(list))
})

test_that("says FALSE to non-list", {
  expect_false(suppressWarnings(check_for_sublist(1)))
})

test_that("handles empty object (should be false)", {
  expect_false(suppressWarnings(check_for_sublist(NULL)))
})

list <- list(1)

test_that("handles list of one", {
  expect_false(check_for_sublist(list))
})

list <- list(NULL)

test_that("handles list of none", {
  expect_false(check_for_sublist(list))
})
