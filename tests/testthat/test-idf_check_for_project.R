skip_on_cran()
skip_if_no_couchdb()

# Test that a valid project name does not throw an error
test_that("idf_check_for_project() handles valid project name", {
  conn <- connect_idaifield(pwd = "hallo", project = "rtest", ping = FALSE)
  conn$status <- TRUE
  expect_silent(idf_check_for_project(conn))
})

# Test that an invalid project name throws an error with correct message
test_that("check_for_project() handles invalid project name", {
  conn <- connect_idaifield(pwd = "hallo", project = "invalidproject", ping = FALSE)
  conn$status <- TRUE
  expect_error(idf_check_for_project(conn),
               "The requested project 'invalidproject' does not exist.")
})

# Test that a null project name throws an error
test_that("idf_check_for_project() fails if project is not set", {
  conn <- connect_idaifield(pwd = "hallo", project = "aproject", ping = FALSE)
  conn$status <- TRUE
  conn$project <- NULL
  expect_error(idf_check_for_project(conn))
})
