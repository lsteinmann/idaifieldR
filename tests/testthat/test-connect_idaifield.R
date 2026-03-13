source("../load_testdata.R")

connection <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                                 pwd = "hallo",
                                                 project = "rtest",
                                                 ping = FALSE))
ping <- suppressWarnings(idf_ping(connection))

# Test that project argument is correctly assigned
test_that("project argument is correctly assigned", {
  connection <- suppressWarnings(connect_idaifield(project = "rtest",
                                                   pwd = "hallo",
                                                   ping = FALSE))
  expect_equal(connection$project, "rtest")
})

test_that("Fails when 'projet' is not set.", {
  expect_error(connect_idaifield(project = NULL,
                                   pwd = "hallo",
                                   ping = FALSE),
                 "project")
})

# Test that ping argument is correctly assigned
test_that("ping argument is correctly assigned", {
  connection1 <- suppressWarnings(connect_idaifield(pwd = "hallo",
                                                    project = "rtest",
                                                    ping = TRUE))
  connection2 <- suppressWarnings(connect_idaifield(pwd = "hallo",
                                                    project = "rtest",
                                                    ping = FALSE))

  expect_is(connection1$status, "logical")
  expect_true(is.na(connection2$status))
})



test_that("creates class 'idf_connection_settings'", {
  expect_true(inherits(connection, "idf_connection_settings"))
})

test_that("error, no valid ip", {
  expect_error(connect_idaifield(serverip = NULL, project = "rtest", ping = TRUE))
  expect_error(connect_idaifield(serverip = "klotz", project = "rtest", ping = TRUE))
  expect_error(connect_idaifield(serverip = 123, project = "rtest", ping = TRUE))
  expect_error(connect_idaifield(serverip = "field.idai.world", project = "rtest", ping = TRUE))
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


test_that("adds correct limit to the query (needs updating when test data changes)", {
  conn <- connect_idaifield(pwd = "hallo", project = "rtest", ping = TRUE)
  query <- '{ "selector": { "resource.processor": ["Anna Allgemeinperson"] } }'
  new_query <- add_limit_to_query(query, conn)
  expect_true(grepl("79", new_query))
})

test_that("adds correct limit to the query (needs updating when test data changes)", {
  query <- '{ "selector": { "resource.processor": ["Anna Allgemeinperson"] } }'
  expect_error(add_limit_to_query(query, list(hello = "123")), "idf_connection_settings")
})

