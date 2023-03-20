connection <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                                 pwd = "hallo",
                                                 ping = FALSE))
ping <- try(idf_ping(connection))

if (inherits(ping, "try-error")) {
  ping <- FALSE
} else {
  ping <- TRUE
}

connection$status <- FALSE

test_that("does not work without project being set", {
  expect_error(proj_idf_client(conn = connection, project = NULL),
               "project")
})

test_that("error on failed connection", {
  conn <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                             pwd = "wrongPassword",
                                             ping = FALSE))
  expect_error(suppressWarning(
    proj_idf_client(conn = conn, project = "rtest"))
    )
})

test_that("re-pings when status is FALSE and fails", {
  conn <- connect_idaifield(serverip = "128.0.0.1", pwd = "hallo",
                            project = "rtest", ping = FALSE)
  conn$status <- FALSE
  expect_error(suppressMessages(proj_idf_client(conn = conn, project = "rtest")),
               "connection")
})

test_that("error for non connection-settings-object", {
  expect_error(proj_idf_client(conn = c(1, 2, 3), project = "none"),
               "idf_connection_settings")
})

#### skip
skip_on_cran()
if(!ping) { skip("Tests skipped, no DB-connection") }


conn <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                           pwd = "hallo",
                                           ping = ping))

test_that("returns crul client", {
  proj_conn <- proj_idf_client(conn = conn, project = "rtest")
  expect_true(inherits(proj_conn, "HttpClient"))
})

test_that("sets url", {
  proj_client <- proj_idf_client(conn = conn, project = "rtest",
                                include = "query")
  expect_true(grepl("_find", proj_client$url))
  proj_client <- proj_idf_client(conn = conn, project = "rtest",
                                include = "all")
  expect_true(grepl("_all_docs", proj_client$url))
})

test_that("fails for wrong argument", {
  expect_error(proj_idf_client(conn = conn, project = "rtest",
                                include = "test"), "query")
})


test_that("message with db", {
  project <- "rtest"
  expect_message(proj_idf_client(conn = conn, project = project), project)
})

test_that("sets project from connection", {
  project <- "rtest"
  conn <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                             pwd = "hallo",
                                             project = project,
                                             ping = ping))
  expect_message(proj_idf_client(conn = conn), project)
})

test_that("error on failed connection", {
  conn <- connect_idaifield(serverip = "128.0.0.1", pwd = "hallo",
                            project = "rtest", ping = FALSE)
  expect_error(proj_idf_client(conn = conn), "connection")
})

test_that("re-pings when status is FALSE", {
  conn <- connect_idaifield(serverip = "127.0.0.1", pwd = "hallo",
                            project = "rtest", ping = FALSE)
  conn$status <- FALSE
  expect_message(proj_idf_client(conn = conn, project = "rtest"),
                 "FALSE")
})



