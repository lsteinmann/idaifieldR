source(file = "../load_testdata.R")

test_that("unnest_docs returns a list", {
  expect_identical(class(unnest_docs(test_docs)), "idaifield_resources")
})


items <- sample(seq_along(test_docs), size = 5)

for (item in items) {
  test_that("unnested resource has same id", {
    expect_identical(unnest_docs(test_docs)[[item]]$id,
                     test_docs[[item]]$id)
    expect_identical(unnest_docs(test_docs)[[item]]$id,
                     test_docs[[item]]$doc$resource$id)
  })

  test_that("relation naming works", {
    greps <- grepl("relations", names(test_resources[[item]]))
    expect_true(any(greps))
  })
}

