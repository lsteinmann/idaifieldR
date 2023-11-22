no_conn <- connect_idaifield(serverip = "123.456.789.999",
                             project = "rtest",
                             pwd = "hallo", ping = FALSE)

test_that("gives warning for invalid connection object", {
  expect_warning(test <- idf_ping(NA), "Did nothing")
  expect_false(test)
})

test_that("gives warning for invalid connection credentials", {
  expect_warning(test <- idf_ping(no_conn), "host")
  expect_false(test)
})




skip_on_cran()
connection <- skip_if_no_connection()

no_conn <- suppressWarnings(connect_idaifield(pwd = "wrongpassword",
                                              project = "rtest",
                                              ping = FALSE))

test_that("warning for connection error", {
  expect_warning(idf_ping(no_conn), "password")
  expect_false(suppressWarnings(idf_ping(no_conn)))
})


test_that("returns TRUE for valid connection", {
  expect_true(idf_ping(connection))
})

