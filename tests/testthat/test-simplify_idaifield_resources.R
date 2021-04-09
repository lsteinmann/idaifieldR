source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)


#test_docs <- test_docs[-which(uidlist$UID == "project")]

item <- 5#sample(seq_along(test_docs), 1)

test_that("error when no identifier", {
  expect_error(simplify_single_resource(test_docs[[item]]),
               "valid")
})

test_that("fail without uidlist when replaceuid = T", {
  expect_error(simplify_single_resource(test_resources[[item]],
                                        replace_uids = TRUE),
               "UID")
})

test_that("pass without uidlist when replaceuid = F", {
  test <- simplify_single_resource(test_resources[[item]],
                                   replace_uids = FALSE)
  expect_identical(class(test), "list")
})


test_that("geomtry is gone", {
  test <- simplify_single_resource(test_resources[[item]], uidlist = uidlist)
  expect_null(test$geometry)
})


test_that("runs without uidlist", {
  expect_s3_class(simplify_idaifield(test_docs), "idaifield_resources")
})

