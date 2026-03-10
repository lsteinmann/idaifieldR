test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))

test_that("unnests to resource level", {
  # Test that the function correctly unnests a list of
  # idaifield_docs to idaifield_resources
  #expect_true(all(sapply(test_docs, function(x) { "doc" %in% names(x) })))
  tmp <- maybe_unnest_docs(test_docs)
  expect_false(all(sapply(tmp, function(x) { "doc" %in% names(x) })))
  expect_true(all(sapply(tmp, function(x) { "identifier" %in% names(x) })))
})

test_that("does not change resource list", {
  test_resources <- maybe_unnest_docs(test_docs)
  # Test that the function does not change the idaifield_resources object
  expect_identical(maybe_unnest_docs(test_resources), test_resources)
})

test_that("maybe_unnest_docs returns input unchanged", {
  tmp <- list("börek", "mehr börek",
              "weniger börek",
              "genau richtig viel börek")
  expect_identical(
    maybe_unnest_docs(tmp),
    tmp
  )
  tmp <- rnorm(10)
  expect_identical(
    maybe_unnest_docs(tmp),
    tmp
  )
})

