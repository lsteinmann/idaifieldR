library(idaifieldR)
connection <- connect_idaifield(pwd = "hallo", project = "rtest")

idaifield_docs <- get_idaifield_docs(connection)
saveRDS(idaifield_docs, file = "inst/testdata/idaifield_test_docs.RDS")

config <- get_configuration(connection)
saveRDS(config, file = "inst/testdata/idaifield_test_config.RDS")

connection <- connect_idaifield(pwd = "hallo", project = "idaifieldr-demo")
idaifieldr_demodata <- get_idaifield_docs(connection = connection)

usethis::use_data(idaifieldr_demodata, overwrite = TRUE)
