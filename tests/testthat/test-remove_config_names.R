# Test that the function removes everything before the colon
test_that("remove_config_names removes everything before the colon", {
  names <- c("relation.liesWithin", "relation.liesWithinLayer",
             "campaign.2022", "rtest:test", "pergamon:neuesFeld")
  correct <- c("relation.liesWithin", "relation.liesWithinLayer",
               "campaign.2022", "test", "neuesFeld")
  expect_identical(remove_config_names(names), correct)
})

# Test that the function returns an error for non-character inputs
test_that("remove_config_names handles list", {
  names <- list(1, 2, "3", "test:test")
  correct <- c(1, 2, "3", "test")
  expect_identical(remove_config_names(names), correct)
})

# Test that the function returns an error for non-character inputs
test_that("remove_config_names can handle NA", {
  names <- c(NA, "test", "test:test")
  correct <- c(NA, "test", "test")
  expect_identical(remove_config_names(names), correct)
})
