



test_that("creats a sofa-cushion", {
  connection <- suppressWarnings(connect_idaifield(serverip = "127.0.0.1", user = "R", pwd = "hallo"))
  expect_true("Cushion" %in% class(connection))
})

test_that("error for non-valid version number", {
  expect_error(connect_idaifield(version = "test"), "valid")
})

test_that("port 3000 for version 2", {
  connection <- suppressWarnings(connect_idaifield(pwd = "hallo", version = 2))
  expect_equal(connection$port, 3000)
})

test_that("port 3002 for version 3", {
  connection <- suppressWarnings(connect_idaifield(version = 3))
  expect_equal(connection$port, 3001)
})

test_that("warning, no connection", {
  expect_warning(connect_idaifield(serverip = "192.168.0.1"), "timeout")
})

test_that("warning, no connection", {
  expect_warning(connect_idaifield(), "running")
})


## Not running on GitHub/Cran
skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({
  sofa::ping(connection)
},
error = function(cond) {
  skip("Test skipped, needs DB-connection")
})

test_that("warning, wrong password", {
  expect_warning(connect_idaifield(serverip = "127.0.0.1", pwd = "falsch"),
                 "password")
})

test_that("warning, wrong version", {
  expect_warning(connect_idaifield(serverip = "127.0.0.1", pwd = "hallo",
                                   version = 2),
                 "version")
})


