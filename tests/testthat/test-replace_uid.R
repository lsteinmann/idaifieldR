source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)
uidlist <- uidlist[-which(uidlist$UID == "project"), ]

test_that("replace_uid does not touch non uid", {
  item <- "börek"
  expect_identical(replace_uid(item = item,
                               uidlist = uidlist),
                   item)
})


sample <- sample(seq_len(nrow(uidlist)), 1)
test_that("replace_uid finds correct name", {
  expect_identical(replace_uid(item = uidlist$UID[sample],
                               uidlist = uidlist),
                   uidlist$identifier[sample])
})
