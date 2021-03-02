
#context("na_if_empty works")

test_that("na_if_empty spots empty vector", {
  expect_identical(na_if_empty(c()), NA)
  expect_identical(na_if_empty(NULL), NA)
  expect_identical(na_if_empty(list()), NA)
})


test_that("na_if_empty returns correct vector", {
  expect_identical(na_if_empty(c(1,2)), c(1,2))
  expect_identical(na_if_empty(c("thales", "of", "miletus")), c("thales", "of", "miletus"))
  expect_identical(na_if_empty(list("thales", "of", "miletus")), list("thales", "of", "miletus"))
})



#context("unnest_resource works")

test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS", package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)

test_that("unnest_resource returns a list", {
  expect_identical(class(unnest_resource(test_resource)), "idaifield_resource")
})

item <- sample(1:length(test_resource), 1)

test_that("unnested resource has same id", {
  expect_identical(unnest_resource(test_resource)[[item]]$id, test_resource[[item]]$id)
  expect_identical(unnest_resource(test_resource)[[item]]$id, test_resource[[item]]$doc$resource$id)
})

test_that("unnest_resource does not process non-list", {
  expect_error(unnest_resource(1), regexp = "not.*.processed")
})

testlist <- list("this", "is", "not", list("what", "I", "want"))

test_that("unnest_resource does not process non-idaifield-lists", {
  expect_error(unnest_resource(testlist), regexp = "not.*.processed")
})






