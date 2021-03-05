library(idaifieldR)
test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                     package = "idaifieldR"))
unnested_test_resource <- unnest_resource(test_resource)
