library(idaifieldR)
connection <- connect_idaifield(pwd = "hallo", project = "rtest")

idaifield_docs <- get_idaifield_docs(connection)
saveRDS(idaifield_docs, file = "inst/testdata/idaifield_test_docs.RDS")

config <- get_configuration(connection)
saveRDS(config, file = "inst/testdata/idaifield_test_config.RDS")

config <- get_configuration(connection, projectname = "anderes-projekt")
saveRDS(config, file = "inst/testdata/empty_config.RDS")

connection <- connect_idaifield(pwd = "hallo", project = "idaifieldr-demo")
idaifieldr_demodata <- get_idaifield_docs(connection = connection)

#saveRDS(demodata, file = "inst/testdata/demodata.RDS")
usethis::use_data(idaifieldr_demodata, overwrite = TRUE)

## NOT (yet) USED
lang_config <- get_configuration(connection = connection)
saveRDS(lang_config, file = "inst/testdata/lang_demo_config.RDS")
