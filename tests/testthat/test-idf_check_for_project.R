

skip_on_cran()
skip_if_no_connection()


conn <- connect_idaifield(pwd = "hallo", project = "rtest", ping = FALSE)

conn$status <- TRUE

# Test that a valid project name does not throw an error
test_that("idf_check_for_project() handles valid project name", {
  expect_silent(idf_check_for_project(conn, project = "rtest"))
})

# Test that an invalid project name throws an error with correct message
test_that("check_for_project() handles invalid project name", {
  expect_error(idf_check_for_project(conn, project = "invalidproject"),
               "The requested project 'invalidproject' does not exist.")
})

# Test that a null project name throws an error
test_that("idf_check_for_project() handles null project name", {
  conn$project <- NULL
  expect_error(idf_check_for_project(conn), "project")
})

# Test that passing in a project name to the function overrides the connection settings
test_that("idf_check_for_project() overrides connection project setting", {
  expect_silent(idf_check_for_project(conn, project = "test"))
  expect_error(idf_check_for_project(conn, project = "myotherproject"),
               "The requested project 'myotherproject' does not exist.")
})
