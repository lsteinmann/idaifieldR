source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)



items <- sample(seq_along(test_resources), size = 5)
for (item in items) {
  print(paste("--------------------------###### Nr.: ", item))

  test_that("error when no identifier", {
    test_resources[[item]]$identifier <- NULL
    expect_error(simplify_single_resource(test_resources[[item]]),
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
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist,
                                       keep_geometry = FALSE)
      expect_null(test$geometry)
    })

    test_that("geometry is matrix", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist,
                                       keep_geometry = TRUE)
      test <- test$geometry
      expect_true("matrix" %in% class(test$coordinates[[1]]))
    })
  }

  if (!is.null(test_resources[[item]]$dimensionLength)) {
    test_that("dimension is replaced", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist)
      expect_true(any(grepl("_cm_1", names(test))))
    })
  }

  if (!is.null(test_resources[[item]]$dimensionThickness)) {
    test_that("dimension is replaced", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist)
      expect_true(any(grepl("_cm_1", names(test))))
    })
  }
}

test_that("runs without uidlist", {
  expect_s3_class(simplify_idaifield(test_docs), "idaifield_simple")
})

simple <- simplify_idaifield(test_docs)

test_that("contains no special config names in columns", {
  expect_false(any(grepl(":", names(simple))))
})

