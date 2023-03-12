library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- unnest_docs(test_docs)

config <- readRDS(system.file("testdata", "rtest_config.RDS",
                                   package = "idaifieldR"))
