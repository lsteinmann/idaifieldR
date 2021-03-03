test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                     package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)


test_that("idaifield_as_df returns a data.frame", {
  check <- idaifield_as_df(test_resource)
  expect_identical(class(check), "data.frame")
})
