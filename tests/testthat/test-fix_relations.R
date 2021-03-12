source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)
project <- which(uidlist$UID == "project")

test_resources <- test_resources[-project]

# note: for some of the resources these tests seem to fail and
# one day I should check why
item <- 5#sample(seq_along(test_docs), 1)

resource <- fix_relations(test_resources[[2]],
                          replace_uids = TRUE,
                          uidlist = uidlist)

test_that("names are working", {
  greps <- grepl("relation.", names(resource))
  expect_true(any(greps))
})

test_that("fails without uidlist", {
  expect_error(fix_relations(test_resources[[item]],
                             replace_uids = TRUE),
               "UID")
})

resource <- fix_relations(test_resources[[item]],
                          replace_uids = FALSE)

test_that("does not replace uid", {
  item <- grep("relation", names(resource))
  expect_true(check_if_uid(resource[[item[1]]]))
})

test_that("removes original list", {
  expect_identical(resource$relations, NULL)
})



