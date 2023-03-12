


emptylist <- config$languages
emptylist$en <- list()

test_that("throws error for empty language list", {
  expect_error(prep_language_list(emptylist, language = "en"),
               "empty")
})

langlist <- config$languages
names(langlist) <- c("de", "englisch", "ar")

test_that("throws error for wrong names", {
  expect_error(prep_language_list(langlist, language = "en"),
               "format")
})

test_that("returns a df with var and label", {
  lookup <- prep_language_list(config$languages, language = "en")
  expect_equal(colnames(lookup), c("var", "label"))
})





skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({
  sofa::ping(connection)
},
error = function(cond) {
  skip("Test skipped, needs DB-connection")
})

config <- get_configuration(connection, projectname = "milet")

