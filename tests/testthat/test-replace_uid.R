source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)
uidlist <- uidlist[-which(uidlist$UID == "project"), ]
uidlist <- uidlist[-which(uidlist$UID == "configuration"), ]

test_that("replace_uid does not touch non uid", {
  item <- "börek"
  expect_identical(replace_uid(uidvector = item,
                               uidlist = uidlist),
                   item)
})


sample <- sample(seq_len(nrow(uidlist)), 1)
test_that("replace_uid finds correct name", {
  expect_identical(replace_uid(uidvector = uidlist$UID[sample],
                               uidlist = uidlist),
                   uidlist$identifier[sample])
})


sample <- sample(seq_len(nrow(uidlist)), 10)
test_that("replace_uid finds correct name when vector", {
  expect_identical(replace_uid(uidvector = uidlist$UID[sample],
                               uidlist = uidlist),
                   uidlist$identifier[sample])
})
#uidvector <- c("1f0e60ff-826d-450f-ba39-d68eadcb8f41",
#               "1f1ed5bc-975e-48f0-a215-9b0ecf64bdd2",
#               "1f23e1d5-c066-42fb-8611-7cbe62b83b48",
#               "abcdefd5-abc1-123a-aa11-a1a1a1a1a1a1")

#test_that("the function checks for remaining UUIDs in uidvector and
#          returns a warning message if any are found", {
#            expect_message(replace_uid(uidvector, uidlist),
#                           "Not all UIDs were replaced.")
#})
