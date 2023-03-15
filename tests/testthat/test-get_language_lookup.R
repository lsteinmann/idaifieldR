


emptylist <- config$languages
emptylist$en <- list()

test_that("throws error for empty language list", {
  expect_error(get_language_lookup(emptylist, language = "en"),
               "empty")
})

langlist <- config$languages
names(langlist) <- c("de", "englisch", "ar")

test_that("throws error for wrong names", {
  expect_error(get_language_lookup(langlist, language = "en"),
               "format")
})

test_that("returns a df with var and label", {
  lookup <- get_language_lookup(config$languages, language = "en")
  expect_equal(colnames(lookup), c("var", "label"))
})





skip_on_cran()


connection <- skip_if_no_connection()

config <- get_configuration(connection, projectname = "rtest")

