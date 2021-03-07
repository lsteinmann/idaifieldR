source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)
project <- which(uidlist$UID == "project")

test_resources <- test_resources[-project]

item <- sample(seq_along(test_docs), 1)

resource <- fix_relations(test_resources[[2]],
                          replace_uid = TRUE,
                          uidlist = uidlist)

test_that("names are working", {
  greps <- grepl("relation.", names(resource))
  expect_true(any(greps))
})

test_that("fails without uidlist", {
  expect_error(fix_relations(test_resources[[item]],
                             replace_uid = TRUE),
               "UID")
})

resource <- fix_relations(test_resources[[item]],
                          replace_uid = FALSE)

test_that("does not replace uid", {
  item <- grep("relation", names(resource))
  expect_true(check_if_uid(resource[[item[1]]]))
})

test_that("removes original list", {
  expect_identical(resource$relations, NULL)
})
