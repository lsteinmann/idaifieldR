skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({sofa::ping(connection)},
         error = function(cond) {
           skip("Test skipped, needs DB-connection")
           })

test_that("returns list", {
  res <- idf_query(connection, project = "rtest",
                   field = "type", value = "Layer")
  expect_true(is.list(res))
})


