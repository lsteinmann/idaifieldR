source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

#item <- sample(seq_along(test_docs), 1)

for (i in seq_along(test_docs)) {

  item <- i

if (length(test_resources[[item]]$relations) > 0) {
  resource <- fix_relations(test_resources[[item]],
                            replace_uids = TRUE,
                            uidlist = uidlist)
  test_that("names are working", {
    greps <- grepl("relation.", names(resource))
    expect_true(any(greps))
  })

  resource <- fix_relations(test_resources[[item]],
                            replace_uids = FALSE)



  test_that("does not replace uid", {
    item <- grep("relation", names(resource))
    expect_true(check_if_uid(resource[[item[1]]]))
  })

}


test_that("fails without uidlist for items with relations", {
  if (length(test_resources[[item]]$relations) > 0) {
    expect_error(fix_relations(test_resources[[item]],
                               replace_uids = TRUE),
                 "UID")
  } else {
    test <- fix_relations(test_resources[[item]],
                          replace_uids = TRUE)
    expect_null(test$relations)
  }
})




test_that("removes original list", {
  expect_identical(resource$relations, NULL)
})


}
