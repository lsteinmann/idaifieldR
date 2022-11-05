source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

items <- sample(seq_along(test_docs), size = 10)

for (item in items) {

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
      check <- all(check_if_uid(resource[[item[1]]]))
      expect_true(check)
    })


    test_that("removes original list", {
      expect_identical(resource$relations, NULL)
    })

  }


  test_that("fails without uidlist", {
    expect_error(fix_relations(test_resources[[item]],
                               replace_uids = TRUE),
                 "*.UID.*")
  })

}
