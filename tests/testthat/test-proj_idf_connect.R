connection <- suppressWarnings(connect_idaifield(serverip = "127.0.0.1",
                                                 project = "rtest",
                                                 pwd = "hallo",
                                                 ping = FALSE))
ping <- suppressWarnings(idf_ping(connection))


connection$status <- FALSE


test_that("error on failed connection", {
  conn <- suppressMessages(connect_idaifield(serverip = "127.0.0.1",
                                             pwd = "wrongPassword",
                                             project = "rtest",
                                             ping = FALSE))
  expect_error(expect_warning(proj_idf_client(conn = conn)))
})

test_that("re-pings when status is FALSE and fails", {
  conn <- connect_idaifield(serverip = "128.0.0.1", pwd = "hallo",
                            project = "rtest", ping = FALSE)
  conn$status <- FALSE
  expect_error(expect_warning(proj_idf_client(conn = conn)),
               "connection")
})

test_that("error for non connection-settings-object", {
  expect_error(proj_idf_client(conn = c(1, 2, 3)),
               "idf_connection_settings")
})

#### skip
skip_on_cran()
if(!ping) { skip("Tests skipped, no DB-connection") }


test_that("does not work without project being set", {
  connection$project <- NULL
  expect_error(expect_warning(proj_idf_client(conn = connection),
                              "project"))
  expect_warning(proj_idf_client(conn = connection, project = "rtest"),
                 "project")
})

conn <- suppressWarnings(connect_idaifield(serverip = "127.0.0.1",
                                           pwd = "hallo",
                                           project = "rtest",
                                           ping = ping))

test_that("returns crul client", {
  proj_conn <- proj_idf_client(conn = conn, )
  expect_true(inherits(proj_conn, "HttpClient"))
})

test_that("sets url", {
  proj_client <- proj_idf_client(conn = conn,
                                include = "query")
  expect_true(grepl("_find", proj_client$url))
  proj_client <- proj_idf_client(conn = conn,
                                include = "all")
  expect_true(grepl("_all_docs", proj_client$url))
})

test_that("fails for wrong argument", {
  expect_error(proj_idf_client(conn = conn,
                               include = "test"), "query")
})


test_that("message with db", {
  project <- "rtest"
  expect_message(proj_idf_client(conn = conn), project)
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
  expect_error(suppressWarnings(proj_idf_client(conn = conn)), "connection")
})

test_that("re-pings when status is FALSE", {
  conn <- connect_idaifield(serverip = "127.0.0.1", pwd = "hallo",
                            project = "rtest", ping = FALSE)
  conn$status <- FALSE
  expect_message(proj_idf_client(conn = conn),
                 "FALSE")
})



