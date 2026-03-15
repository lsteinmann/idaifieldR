# TODO for this test:
# It would actually be better to build specific test-case-resources in the
# database with the different kinds of relations, number of entries, etc.,
# and select them deliberately from the test-data. But nobody has time for that.
index <- make_index(test_docs)

items <- sample(seq_along(test_docs), size = 10)

for (item in items) {
  if (length(test_docs[[item]]$doc$resource$relations) > 0) {
    resource <- fix_relations(test_docs[[item]]$doc$resource,
                              replace_uids = TRUE,
                              index = index)
    test_that("names are working", {
      greps <- grepl("relation.", names(resource))
      expect_true(any(greps))
    })

    test_that("does not replace uid", {
      resource <- fix_relations(test_docs[[item]]$doc$resource,
                                replace_uids = FALSE)
      item <- grep("relation", names(resource))
      check <- all(check_if_uid(resource[[item[1]]]))
      expect_true(check)
    })

    test_that("removes original list", {
      resource <- fix_relations(test_docs[[item]]$doc$resource,
                                replace_uids = FALSE)
      expect_identical(resource$relations, NULL)
    })
  }
}


test_that("fails without index", {
  expect_error(fix_relations(test_resources[[item]],
                             replace_uids = TRUE),
               "index")
})
