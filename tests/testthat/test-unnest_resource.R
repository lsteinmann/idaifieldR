test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                     package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)

test_that("unnest_resource returns a list", {
  expect_identical(class(unnest_resource(test_resource)), "idaifield_resource")
})

item <- sample(seq_len(length(test_resource)), 1)

test_that("unnested resource has same id", {
  expect_identical(unnest_resource(test_resource)[[item]]$id,
                   test_resource[[item]]$id)
  expect_identical(unnest_resource(test_resource)[[item]]$id,
                   test_resource[[item]]$doc$resource$id)
})

test_that("unnest_resource does not process non-list", {
  expect_error(unnest_resource(1), regexp = "not.*.processed")
})

testlist <- list("this", "is", "not", list("what", "I", "want"))

test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(testlist), regexp = "not.*.processed")
})
