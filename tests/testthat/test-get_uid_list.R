source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)


test_that("project exists", {
  expect_true("project" %in% uidlist$UID)
})

test_that("config does not exist", {
  expect_false("configuration" %in% uidlist$UID)
})


uidlist <- uidlist[-which(uidlist$UID == "project"), ]

test_that("contains no special config names", {
  expect_false(any(grepl(":", unique(uidlist$type))))
})

samples <- sample(seq_len(nrow(uidlist)), size = 5)

for (sample in samples) {

  test_that("returns uids in correct column", {
    expect_true(check_if_uid(uidlist$UID[sample]))
  })

  test_that("i did not change column order", {
    expect_true(check_if_uid(uidlist[sample, 2]))
  })

  colnames <- colnames(get_uid_list(test_docs, verbose = TRUE))

  test_that("uidlist has the short description when verbose", {
    expect_true(any(grepl("shortDescription", colnames)))
  })

  colnames <- colnames(get_uid_list(test_docs,
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
    expect_equal(ncol(get_uid_list(test_docs)), 5)
  })

  test_that("uidlist has 7 cols when verbose", {
    expect_equal(ncol(get_uid_list(test_docs, verbose = TRUE)), 7)
  })
}

test_that("gets uidlist from simplified list", {
  test <- get_uid_list(simplify_idaifield(test_resources))
  expect_true("Schnitt 1" %in% test$isRecordedIn)
})

test_that("gets uidlist from simplified list", {
  test <- get_uid_list(simplify_idaifield(test_resources))
  expect_true("Befund_6" %in% test$liesWithin)
})

data("idaifieldr_demodata")
test_that("works with multilang demodata from default config", {
  test <- get_uid_list(idaifieldr_demodata)
  expect_true("LAYER_1" %in% test$liesWithin)
})

test_that("works with multilang demodata from default config when verbose", {
  test <- get_uid_list(idaifieldr_demodata, verbose = TRUE)
  expect_true("Another Trench" %in% test$shortDescription)
})

test_that("works with multilang demodata from default config when verbose", {
  test <- get_uid_list(idaifieldr_demodata, verbose = TRUE, language = "de")
  expect_true("Ein Erdbefund" %in% test$shortDescription)
})
