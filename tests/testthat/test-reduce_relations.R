source(file = "../load_testdata.R")

test_that("warns for multiple relations", {
  x <- test_resources[[1]]
  x$relations$liesWithin <- append(x$relations$liesWithin, "bla")
  expect_warning(reduce_relations(x$relations["liesWithin"], x$id, x$identifier),
                 "liesWithin")
})

test_that("warns for multiple relations", {
  x <- test_resources[[1]]
  x$relations$isRecordedIn <- append(x$relations$isRecordedIn, "bla")
  expect_warning(reduce_relations(x$relations["isRecordedIn"], x$id, x$identifier),
                 "isRecordedIn")
})

test_that("leaves intact if only one relation exists", {
  x <- test_resources[[1]]
  expect_identical(reduce_relations(x$relations["liesWithin"], x$id, x$identifier),
                   x$relations["liesWithin"])
})

test_that("removes more than one relation", {
  x <- test_resources[[1]]
  x$relations$liesWithin <- append(x$relations$liesWithin, c("bla", "blubb"))
  expect_warning(new <- reduce_relations(x$relations["liesWithin"], x$id, x$identifier),
                 "liesWithin")
  expect_equal(length(new[[1]]), 1)
})





