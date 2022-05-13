skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({sofa::ping(connection)},
         error = function(cond) {
           skip("Test skipped, needs DB-connection")
         })

uidlist <- get_uid_list(get_idaifield_docs(connection, projectname = "rtest"))

test_that("returns list", {
  res <- idf_query(connection, project = "rtest",
                   field = "type", value = "Layer",
                   uidlist = uidlist)
  expect_equal(class(res), "idaifield_resources")
})

test_that("returns appropriate entries", {
  res <- idf_index_query(connection, project = "rtest",
                   field = "isRecordedIn", value = "Schnitt 1",
                   uidlist = uidlist)
  test <- lapply(res, function(x) x$relation.isRecordedIn)
  test <- unlist(test) == "Schnitt 1"
  expect_true(all(test))
})

test_that("returns appropriate number of entries", {
  count <- unname(table(uidlist$liesWithin)["Befund_6"])
  res <- idf_index_query(connection, project = "rtest",
                         field = "liesWithin", value = "Befund_6",
                         uidlist = uidlist)
  expect_equal(length(res), count)
})
