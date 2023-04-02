
testlist <- list(docs = list(list(resource = list(test = "test",
                                                  test2 = "test2")),
                             list(resource = list(test = "test",
                                                  test2 = "test2"))),
                 warning = "warning")

rowslist <- list(rows = list(list(resource = list(test = "test",
                                                  test2 = "test2")),
                             list(resource = list(test = "test",
                                                  test2 = "test2"))),
                 total_rows = "2")


faillist <- list(docs = list(list(nores = list(test = "test",
                                               test2 = "test2")),
                             list(nores = list(test = "test",
                                               test2 = "test2"))),
                 warning = "warning")


test_that("warns & exits for failure to find list", {
  expect_warning(find_resource(faillist), "resource")
})

test_that("returns correct lists", {
  expect_identical(find_resource(testlist),
                   lapply(testlist$docs, function(x) x$resource))
})

test_that("returns correct lists", {
  expect_identical(find_resource(rowslist),
                   lapply(rowslist$rows, function(x) x$resource))
})


source(file = "../load_testdata.R")


test_that("works with test_docs", {
  expect_identical(find_resource(test_docs),
                   lapply(test_docs, function(x) x$doc$resource))
})




