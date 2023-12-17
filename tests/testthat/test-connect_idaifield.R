connection <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                                 pwd = "hallo",
                                                 project = "rtest",
                                                 ping = FALSE))
ping <- suppressWarnings(idf_ping(connection))

# Test that version is coerced to numeric
test_that("version is coerced to numeric", {
  connection <- suppressWarnings(connect_idaifield(version = "3",
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = FALSE))
  expect_true(grepl("3001", connection$settings$base_url))
  expect_is(connection$settings$base_url, "character")
  expect_is(connection$status, "logical")
  expect_is(connection$project, "character")
})

# Test that version less than 3 is set to 2
test_that("version less than 3 is set to 2", {
  connection <- suppressWarnings(connect_idaifield(version = 1,
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = FALSE))
  expect_true(grepl("3000", connection$settings$base_url))
})

# Test that project argument is correctly assigned
test_that("project argument is correctly assigned", {
  connection <- suppressWarnings(connect_idaifield(version = 3,
                                                   project = "rtest",
                                                   pwd = "hallo",
                                                   ping = FALSE))
  expect_equal(connection$project, "rtest")
})

test_that("error and warning is issued when no project is supplied", {
  expect_error(expect_warning(connect_idaifield(version = 3,
                                   project = NULL,
                                   pwd = "hallo",
                                   ping = FALSE)),
                 "project")
})

# Test that ping argument is correctly assigned
test_that("ping argument is correctly assigned", {
  connection1 <- suppressWarnings(connect_idaifield(version = 3,
                                                    pwd = "hallo",
                                                    project = "rtest",
                                                    ping = TRUE))
  connection2 <- suppressWarnings(connect_idaifield(version = 3,
                                                    pwd = "hallo",
                                                    project = "rtest",
                                                    ping = FALSE))

  expect_is(connection1$status, "logical")
  expect_true(is.na(connection2$status))
})



test_that("creates class 'idf_connection_settings'", {
  expect_true(inherits(connection, "idf_connection_settings"))
})

test_that("error for non-valid version number", {
  expect_error(connect_idaifield(version = "test",
                                 project = "rtest",
                                 ping = ping),
               "valid")
})

test_that("port 3001 for version 3", {
  connection <- suppressMessages(connect_idaifield(version = 3,
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = ping))
  expect_true(grepl("3001", connection$settings$base_url))
})

test_that("port 3001 for version 3, works with '3'", {
  connection <- suppressMessages(connect_idaifield(version = "3",
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = ping))
  expect_true(grepl("3001", connection$settings$base_url))
})
test_that("port 3001 for version 4", {
  connection <- suppressMessages(connect_idaifield(version = 4,
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = ping))
  expect_true(grepl("3001", connection$settings$base_url))
})

test_that("port 3000 for version 2", {
  connection <- suppressMessages(connect_idaifield(version = "2",
                                                   pwd = "hallo",
                                                   project = "rtest",
                                                   ping = FALSE))
  expect_true(grepl("3000", connection$settings$base_url))
})

test_that("error, no valid ip", {
  expect_error(connect_idaifield(serverip = NULL, project = "rtest", ping = TRUE))
  expect_error(connect_idaifield(serverip = "klotz", project = "rtest", ping = TRUE))
  expect_error(connect_idaifield(serverip = 123, project = "rtest", ping = TRUE))
})

test_that("auth object attached", {
  expect_is(connect_idaifield(ping = FALSE, project = "rtest")$settings$auth, "auth")
})

test_that("application/json in header", {
  headers <- connect_idaifield(ping = FALSE, project = "rtest")$settings$headers
  expect_true("application/json" %in% headers)
})

skip_on_cran()
conn <- skip_if_no_connection()

test_that("error, project does not exist", {
  expect_error(connect_idaifield(pwd = "hallo", project = "rtsdsaest",
                                 ping = TRUE), "project")
})

test_that("error, no connection", {
  expect_warning(connect_idaifield(pwd = "wrongpwd", project = "rtest", ping = TRUE))
})


