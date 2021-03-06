source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_resource)
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


#sample <- sample(seq_len(nrow(uidlist)), 3)
#list <- list(uidlist$UID[sample])

#test_that("replace_uid finds correct name", {
#  expect_identical(replace_uid(item = list,
#                               uidlist = uidlist),
#                   uidlist$identifier[sample])
#})


#sample <- sample(seq_len(nrow(uidlist)), 4)
#replace_single_uid(item = uidlist$UID[sample], uidlist = uidlist)
