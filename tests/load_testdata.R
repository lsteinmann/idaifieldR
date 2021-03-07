library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- unnest_resource(test_docs)
