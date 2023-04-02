input_list <- list(list("en" = "English text", "de" = "Deutscher Text"),
                   list("en" = "Another english text", "de" = "Weiterer dt. Text"),
                   list("fr" = "donc", "en" = "well"),
                   list("de" = "erst de", "en" = "dann en"))


test_that("returns a vector of same length", {
  expect_equal(length(input_list), length(gather_languages(input_list)))
})

test_that("no names", {
  expect_named(names(gather_languages(input_list)), NULL)
})

test_that("uses language where available", {
  out <- gather_languages(input_list, language = "fr")
  expect_equal(out[3], "donc")
})

test_that("uses alphabetically first language where choice not available", {
  out <- gather_languages(input_list, language = "fr")
  expect_identical(out[1], "Deutscher Text")
})

test_that("warning when language inexistent", {
  expect_warning(gather_languages(input_list, language = "tr"),
                 "No language")
})

input_list <- lapply(test_resources, function(x) x$shortDescription)
test_that("works for single language test_resources", {
  expect_identical(length(input_list),
                   length(gather_languages(input_list)))
})

input_list <- list("Text", "More Text", "even more text")
test_that("works with a simple list without languages", {
  out <- gather_languages(input_list, language = "fr")
  expect_identical(class(out), "character")
  expect_identical(out[3], "even more text")
})

data(idaifieldr_demodata)
data <- check_and_unnest(idaifieldr_demodata)
input_list <- lapply(data, function(x) x$shortDescription)
test_that("works for demo data with more than one language", {
  out <- gather_languages(input_list, language = "en")
  expect_identical(length(out), length(data))
})

test_that("also warning if language not available", {
  expect_warning(gather_languages(input_list, language = "tr"),
                 "No language")
})

test_that("pastes languages when language = 'all'", {
  expect_match(gather_languages(input_list, language = "all"), ":")
})

