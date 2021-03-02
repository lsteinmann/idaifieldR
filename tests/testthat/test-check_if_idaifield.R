

test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS", package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)



test_that("checking works for docs-lists", {
  expect_identical(unname(check_if_idaifield(test_resource)[1,"idaifield_docs"]), TRUE)
})



test_that("checking works for resource-lists", {
  expect_identical(unname(check_if_idaifield(unnested_test_resource)[1,"idaifield_resource"]), TRUE)
})

test_that("checking works for resource-lists", {
  expect_identical(unname(check_if_idaifield(unnest_resource(test_resource))[1,"idaifield_resource"]), TRUE)
})

