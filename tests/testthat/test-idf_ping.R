no_conn <- suppressWarnings(connect_idaifield(serverip = "123.456.789.999",
                                              pwd = "hallo"))
test_that("character for error", {
  expect_is(idf_ping(no_conn), "character")
})

skip_on_cran()
connection <- skip_if_no_connection()

no_conn <- suppressWarnings(connect_idaifield(pwd = "wrongpassword"))
test_that("character for error", {
  expect_match(idf_ping(no_conn), "password")
})

test_that("returns TRUE for working connection", {
  expect_true(idf_ping(connection))
})
