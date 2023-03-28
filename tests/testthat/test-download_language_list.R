## Not running on GitHub/Cran
skip_on_cran()

skip("Bla")

test_that("is a list", {
  expect_identical(class(download_language_list()), "list")
})

test_that("gets list for project", {
  expect_identical(class(download_language_list(project = "milet")), "list")
})


