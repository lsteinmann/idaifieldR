# Test that the function removes everything before the colon
test_that("remove_config_names removes everything before the colon", {
  names <- c("relation.liesWithin", "relation.liesWithinLayer",
             "campaign.2022", "rtest:test", "pergamon:neuesFeld")
  correct <- c("relation.liesWithin", "relation.liesWithinLayer",
               "campaign.2022", "test", "neuesFeld")
  expect_contains(remove_config_names(names), correct)
  no_attrib <- remove_config_names(names)
  attributes(no_attrib) <- NULL
  expect_identical(no_attrib, correct)
})

# Test that the function returns an error for non-character inputs
test_that("remove_config_names handles list", {
  names <- list(1, 2, "3", "test:test")
  correct <- c(1, 2, "3", "test")
  expect_contains(remove_config_names(names), correct)
  no_attrib <- remove_config_names(names)
  attributes(no_attrib) <- NULL
  expect_identical(no_attrib, correct)
})

# Test that the function returns an error for non-character inputs
test_that("remove_config_names can handle NA", {
  names <- c(NA, "test:test")
  correct <- c(NA, "test")
  expect_contains(remove_config_names(names), correct)
  no_attrib <- remove_config_names(names)
  attributes(no_attrib) <- NULL
  expect_identical(no_attrib, correct)
})

# Test that the function warns about duplicate field names
test_that("remove_config_names can handle duplicates", {
  names <- c(NA, "test", "test:test")
  correct <- c(NA, "test", "test")
  expect_message(remove_config_names(names, silent = FALSE), "duplicate")
})

# Test that the function warns about duplicate field names
test_that("remove_config_names attaches attribute", {
  names <- c(NA, "test", "test:test")
  attributes <- attributes(remove_config_names(names, silent = TRUE))
  expect_contains(names(attributes), "duplicate_names")
  dupl <- attributes$duplicate_names
  expect_identical(dupl, "test")
})

