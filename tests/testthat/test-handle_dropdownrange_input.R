# ---- handle_dropdownrange_input() ------------------------------------------------------

test_that("handles a single starting value", {
  input <- list(value = "Classical")
  result   <- handle_dropdownrange_input(input, "input")
  expected <- list(input.start = "Classical", input.end = "Classical")
  expect_identical(result, expected)
})

test_that("handles current format with range", {
  input <- list(value = "Classical", endValue = "Hellenistic")
  result   <- handle_dropdownrange_input(input, "input")
  expected <- list(input.start = "Classical", input.end = "Hellenistic")
  expect_identical(result, expected)
})

test_that("sets NA if start value is missing - this should never happen", {
  result <- handle_dropdownrange_input(
    list(endValue = "end"),
    "input"
  )
  expected <- list(input.start = NA, input.end = "end")
  expect_identical(result, expected)
})

test_that("names output after the supplied field name", {
  input <- list(value = "Classical", endValue = "Hellenistic")
  result   <- handle_dropdownrange_input(input, "ThisIsThe_Name")
  expected <- list(ThisIsThe_Name.start = "Classical", ThisIsThe_Name.end = "Hellenistic")
  expect_identical(result, expected)
})

test_that("returns a warning and NA list for unexpected input", {
  input <- list(incompatible = "Yes")
  result   <- handle_dropdownrange_input(input, "input")
  expected <- list(input.start = NA, input.end = NA)
  expect_identical(result, expected)
})
