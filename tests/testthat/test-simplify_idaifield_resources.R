source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

items <- sample(seq_along(test_resources), size = 5)

for (item in items) {
  print(paste("-----------------------------------------------###### Nr.: ", item))

  test_that("error when no identifier", {
    expect_error(simplify_single_resource(test_docs[[item]]),
                 "valid")
  })

  test_that("fail without uidlist when replaceuid = T", {
    expect_error(simplify_single_resource(test_resources[[item]],
                                          replace_uids = TRUE,
                                          uidlist = NULL))
  })

  test_that("pass without uidlist when replaceuid = F", {
    test <- simplify_single_resource(test_resources[[item]],
                                     replace_uids = FALSE,
                                     uidlist = NULL)
    expect_identical(class(test), "list")
  })

  if (!is.null(test_resources[[item]]$geometry)) {
    test_that("geomtry is gone", {
      test <- simplify_single_resource(test_resources[[item]], uidlist = uidlist)
      expect_null(test$geometry)
    })

    test_that("geomtry is matrix", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist,
                                       keep_geometry = TRUE)
      test <- test$geometry
      expect_true("matrix" %in% class(test$coordinates[[1]]))
    })
  }




  test_that("runs without uidlist", {
    expect_s3_class(simplify_idaifield(test_docs), "idaifield_resources")
  })
}


