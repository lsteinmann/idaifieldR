skip_on_cran()

connection <- skip_if_no_connection()

uidlist <- get_uid_list(get_idaifield_docs(connection))

test_that("returns idaifield_docs", {
  res <- idf_query(connection,
                   field = "category", value = "Layer")
  expect_equal(class(res), "idaifield_docs")
})


test_that("returns appropriate entries", {
  res <- idf_index_query(connection,
                   field = "isRecordedIn", value = "Schnitt 1",
                   uidlist = uidlist)
  test <- check_and_unnest(res)
  test <- lapply(res, function(x) x$relation.isRecordedIn)
  test <- unlist(test) == "Schnitt 1"
  expect_true(all(test))
})

test_that("returns appropriate number of entries", {
  count <- unname(table(uidlist$liesWithin)["Befund_6"])
  res <- idf_index_query(connection,
                         field = "liesWithin", value = "Befund_6",
                         uidlist = uidlist)
  expect_equal(length(res), count)
})

test_that("error when field not in uidlist", {
  expect_error(idf_index_query(connection,
                         field = "storagePlace", value = "Museum",
                         uidlist = uidlist))
})

test_that("returns appropriate number of entries", {
  count <- unlist(lapply(test_resources, function(x) x$storagePlace))
  count <- sum(count == "Museum")
  res <- idf_query(connection, field = "storagePlace", value = "Museum")
  expect_equal(length(res), count)
})

test_that("works for relations", {
  uid <- uidlist[which(uidlist$identifier == "Befund_6"), "UID"]
  res <- idf_query(connection, field = "relations.liesWithin", value = uid)
  liesWithin <- unlist(lapply(res, function(x) x$doc$resource$relations$liesWithin))
  expect_true(all(liesWithin == uid))
})

test_that("works for campaign field", {
  res <- idf_query(connection, field = "campaign", value = "2021")
  expect_gt(length(res), 1)
})

test_that("works for other fields with single values", {
  res <- idf_query(connection, field = "storagePlace", value = "Museum")
  expect_gt(length(res), 1)
})




