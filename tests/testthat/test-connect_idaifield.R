connection <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                                 pwd = "hallo",
                                                 ping = FALSE))
ping <- try(idf_ping(connection))

if (inherits(ping, "try-error")) {
  ping <- FALSE
} else {
  ping <- TRUE
}


test_that("creates class 'idf_connection_settings'", {
  expect_true(inherits(connection, "idf_connection_settings"))
})

test_that("error for non-valid version number", {
  expect_error(connect_idaifield(version = "test", ping = ping),
               "valid")
})

test_that("port 3001 for version 3", {
  connection <- suppressMessages(connect_idaifield(version = 3,
                                                   pwd = "hallo",
                                                   ping = ping))
  expect_true(grepl("3001", connection$settings$base_url))
})

test_that("port 3001 for version 3, works with '3'", {
  connection <- suppressMessages(connect_idaifield(version = "3",
                                                   pwd = "hallo",
                                                   ping = ping))
  expect_true(grepl("3001", connection$settings$base_url))
})

test_that("port 3000 for version 2", {
  connection <- suppressMessages(connect_idaifield(version = "2",
                                                   pwd = "hallo",
                                                   ping = FALSE))
  expect_true(grepl("3000", connection$settings$base_url))
})

test_that("error, no connection", {
  expect_warning(connect_idaifield(pwd = "wrongpwd", ping = TRUE))
})

skip_on_cran()
conn <- skip_if_no_connection()

test_that("error, project does not exist", {
  expect_error(connect_idaifield(pwd = "hallo", project = "rtsdsaest",
                                 ping = TRUE), "project")
})




