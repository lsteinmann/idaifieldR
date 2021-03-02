## code to prepare `idaifield_docs_example` dataset goes here

idaifield_test_docs <- get_idaifield_docs(serverip = "192.168.2.21",
                                          projectname = "testproj",
                                          user = "R",
                                          pwd = "hallo",
                                          simplified = FALSE)

write_rds(idaifield_test_docs, "inst/testdata/idaifield_test_docs.RDS")




