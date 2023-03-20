no_conn <- connect_idaifield(serverip = "123.456.789.999",
                             pwd = "hallo", ping = FALSE)

test_that("throws error", {
  expect_error(idf_ping(no_conn))
})

test_that("warning for wrong object", {
  expect_warning(idf_ping(NA))
  expect_false(suppressWarnings(idf_ping(NA)))
})



skip_on_cran()
connection <- skip_if_no_connection()

no_conn <- suppressWarnings(connect_idaifield(pwd = "wrongpassword",
                                              ping = FALSE))

test_that("warning for connection error", {
  expect_warning(idf_ping(no_conn), "password")
  expect_false(suppressWarnings(idf_ping(no_conn)))
})

test_that("returns TRUE for working connection", {
  expect_true(idf_ping(connection))
})


