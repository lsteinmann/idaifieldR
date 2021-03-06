source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)
uidlist <- uidlist[-which(uidlist$UID == "project"), ]

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

  test_that("uidlist has 5 cols by default", {
    expect_equal(ncol(get_uid_list(test_docs)), 5)
  })

  test_that("uidlist has 6 cols when verbose", {
    expect_equal(ncol(get_uid_list(test_docs, verbose = TRUE)), 6)
  })
}


