test_that("creats a sofa-cushion", {
  connection <- connect_idaifield(serverip = "127.0.0.1", user = "R", pwd = "hallo")
  expect_true("Cushion" %in% class(connection))
})

test_that("error for non-valid version number", {
  expect_error(connection <- connect_idaifield(version = "test"), "valid")
})

test_that("port 3000 for version 2", {
  connection <- connect_idaifield(version = 2)
  expect_equal(connection$port, 3000)
})

test_that("port 3002 for version 3", {
  connection <- connect_idaifield(version = 3)
  expect_equal(connection$port, 3001)
})
