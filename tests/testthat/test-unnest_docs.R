source(file = "../load_testdata.R")

test_that("unnest_docs returns a list", {
  expect_identical(class(unnest_docs(test_docs)), "idaifield_resources")
})

test_that("unnest_docs does not process non-list", {
  expect_error(unnest_docs(1), regexp = "resource")
})


test_that("unnest_docs wont process unnested res", {
  expect_error(unnest_docs(test_resources), "resource")
})

testlist <- list("this", "is", "not", list("what", "I", "want"))

test_that("unnest_docs does not process non-idaifield-lists", {
  expect_error(unnest_docs(testlist), regexp = "resource")
})

# TODO
test_that("preserves connection as attribute", {
  test_resources <- unnest_docs(test_docs)
  expect_true(TRUE)
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

