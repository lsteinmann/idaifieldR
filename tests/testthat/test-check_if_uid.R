
test_that("check_if_uid identifies UID", {
  expect_true(check_if_uid(string = "0324141a-8201-c5dc-631b-4dded4552ac4"))
})

test_that("check_if_uid refuses non-UID", {
  expect_false(check_if_uid(string = "börek"))
})

test_that("check_if_uid warns for vector", {
  expect_warning(check_if_uid(string = c(1, 2)))
})
