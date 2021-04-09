source(file = "../load_testdata.R")

test_that("idaifield_as_df returns a data.frame", {
  check <- idaifield_as_df(test_docs)
  expect_identical(class(check), "data.frame")
})
