skip_on_cran()

connection <- skip_if_no_connection()

uidlist <- get_uid_list(get_idaifield_docs(connection, projectname = "rtest"))

test_that("returns idaifield_docs", {
  res <- idf_query(connection, projectname = "rtest",
                   field = "type", value = "Layer")
  expect_equal(class(res), "idaifield_docs")
})


test_that("returns appropriate entries", {
  res <- idf_index_query(connection, projectname = "rtest",
                   field = "isRecordedIn", value = "Schnitt 1",
                   uidlist = uidlist)
  test <- check_and_unnest(res)
  test <- lapply(res, function(x) x$relation.isRecordedIn)
  test <- unlist(test) == "Schnitt 1"
  expect_true(all(test))
})

test_that("returns appropriate number of entries", {
  count <- unname(table(uidlist$liesWithin)["Befund_6"])
  res <- idf_index_query(connection, projectname = "rtest",
                         field = "liesWithin", value = "Befund_6",
                         uidlist = uidlist)
  expect_equal(length(res), count)
})

