source(file = "../load_testdata.R")

test_that("check_and_unnest fails", {
  # Test that the function issues a warning when passed an
  # object that is not an idaifield_docs, idaifield_resources,
  # or idaifield_simple object
  expect_warning(check_and_unnest(
    list("börek", "mehr börek",
         "weniger börek",
         "genau richtig viel börek")))
  # Test that the function issues a warning when passed an object
  # that is not an idaifield_docs, idaifield_resources,
  # or idaifield_simple object
  expect_warning(check_and_unnest(rnorm(10)))
})

# Test that the function processes the input when forced
test_that("processes when forced", {
  # Create an input list with a nested resource field
  list <- list("börek", resource = list("genau richtig viel börek"))
  # Call the function with force = TRUE
  # Expect a warning message indicating that the input was processed
  expect_warning(check_and_unnest(list, force = TRUE))
})

test_that("unnests to resource level", {
  # Test that the function correctly unnests a list of
  # idaifield_docs to idaifield_resources
  expect_identical(check_and_unnest(test_docs), test_resources)
})


test_that("does not change simplified list", {
  test_simple <- list(1, 2, 3)
  class(test_simple) <- "idaifield_simple"
  # Test that the function does not change the idaifield_simple object
  expect_identical(check_and_unnest(test_simple), test_simple)
})

test_that("does not change resource list", {
  # Test that the function does not change the idaifield_resources object
  expect_identical(check_and_unnest(test_resources), test_resources)
})

test_that("keeps attributes", {
  class <- which(names(attributes(test_docs)) == "class")
  # Test that the function retains the attributes of the input object
  expect_identical(attributes(check_and_unnest(test_docs))[-class],
                   attributes(test_docs)[-class])
})

test_that("keeps names", {
  # Test that the function retains the names of the input object
  expect_identical(names(test_docs),
                   names(check_and_unnest(test_docs)))
})
