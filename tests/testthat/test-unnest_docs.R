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

  test_that("unnest_docs does not process non-list", {
    expect_error(unnest_docs(1), regexp = "not.*.processed")
  })

  test_that("unnest_docs messages about already unnested res", {
    expect_message(unnest_docs(test_resources), regexp = "unnested")
    expect_identical(unnest_docs(test_resources), test_resources)
  })

  testlist <- list("this", "is", "not", list("what", "I", "want"))

  test_that("unnest_docs does not process non-idaifield-lists", {
    expect_error(unnest_docs(testlist), regexp = "not.*.processed")
  })

  test_that("relation naming works", {
    greps <- grepl("relations", names(test_resources[[item]]))
    expect_true(any(greps))
  })

  list <- list("börek", "kaffee", list(rep(1, 2, 3)))
  test_that("unnest_docs does not process non-idaifield-lists", {
    expect_error(unnest_docs(list), regexp = "cannot")
  })
}

skip_on_cran()

connection <- skip_if_no_connection()

test_docs <- get_idaifield_docs(projectname = "rtest",
                                connection = connection,
                                raw = TRUE)

test_that("preserves connection as attribute", {
  test_resources <- unnest_docs(test_docs)
  test_conn <- attr(test_resources, "connection")
  pinglist <- sofa::ping(test_conn)
  expect_true(is.list(pinglist))
})
