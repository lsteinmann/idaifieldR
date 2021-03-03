test_that("na_if_empty spots empty vector", {
  expect_identical(na_if_empty(c()), NA)
  expect_identical(na_if_empty(NULL), NA)
  expect_identical(na_if_empty(list()), NA)
})



test_that("na_if_empty returns correct vector", {
  testvector <- c("thales", "of", "miletus")
  testlist <- list("thales", "of", "miletus")
  expect_identical(na_if_empty(c(1, 2)), c(1, 2))
  expect_identical(na_if_empty(testvector), testvector)
  expect_identical(na_if_empty(testlist), testlist)
})
