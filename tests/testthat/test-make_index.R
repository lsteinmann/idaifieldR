uidlist <- make_index(test_docs)

### Deprecated get_uid_list()
test_that("get_uid_list() warns and moves on", {
  expect_warning(
    res <- get_uid_list(test_docs),
    "deprecated"
  )
  expect_identical(res, make_index(test_docs))
})
test_that("warns when deprecated 'remove_config_names' is passed", {
  expect_warning(
    make_index(test_docs, remove_config_names = TRUE),
    "remove_config_names"
  )
})

### Actual tests
test_that("project exists", {
  expect_true("project" %in% uidlist$UID)
})

test_that("config does not exist", {
  expect_false("configuration" %in% uidlist$UID)
})

test_that("type is never empty", {
  expect_false(any(is.na(uidlist$category)))
})

uidlist <- uidlist[-which(uidlist$UID == "project"), ]

test_that("contains special config names", {
  expect_true(any(grepl(":", unique(uidlist$category))))
})

samples <- sample(seq_len(nrow(uidlist)), size = 5)

for (sample in samples) {

  test_that("returns uids in correct column", {
    expect_true(check_if_uid(uidlist$UID[sample]))
  })

  test_that("i did not change column order", {
    expect_true(check_if_uid(uidlist[sample, 2]))
  })

  colnames <- colnames(make_index(test_docs, verbose = TRUE))

  test_that("uidlist has the short description when verbose", {
    expect_true(any(grepl("shortDescription", colnames)))
  })

  colnames <- colnames(make_index(test_docs,
                                    verbose = TRUE,
                                    gather_trenches = TRUE))

  test_that("uidlist is able to group trenches by place", {
    expect_true(any(grepl("Place", colnames)))
  })

  test_that("uidlist has relation.liesWithin", {
    expect_false(all(is.na(uidlist$liesWithin)))
  })

  test_that("uidlist has relation.isRecordedIn", {
    expect_false(all(is.na(uidlist$isRecordedIn)))
  })

  test_that("uidlist has 5 cols by default", {
    expect_equal(ncol(make_index(test_docs)), 5)
  })

  test_that("uidlist has 7 cols when verbose", {
    expect_equal(ncol(make_index(test_docs, verbose = TRUE)), 6)
  })
}

#test_that("gets uidlist from simplified list", {
#  test <- make_index(test_simple)
#  expect_true("Schnitt 1" %in% test$isRecordedIn)
#})


data("idaifieldr_demodata")
test_that("works with multilang demodata from default config", {
  test <- make_index(idaifieldr_demodata)
  expect_true("LAYER_1" %in% test$liesWithin)
})

test_that("works with multilang demodata from default config when verbose", {
  test <- make_index(idaifieldr_demodata, verbose = TRUE, language = "en")
  expect_true("Another Trench" %in% test$shortDescription)
})

test_that("works with multilang demodata from default config when verbose", {
  test <- make_index(idaifieldr_demodata, verbose = TRUE, language = "de")
  expect_true("Ein Erdbefund" %in% test$shortDescription)
})
