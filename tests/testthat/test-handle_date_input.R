# Tests for handle_date_input() and handle_legacy_date_range_fields().

# ---- handle_date_input() ------------------------------------------------------

test_that("handles legacy single-field date (plain string)", {
  result   <- handle_date_input("12.03.2026", "legacyDate")
  expected <- list(legacyDate.start = "12.03.2026", legacyDate.end = NA)
  expect_identical(result, expected)
})

test_that("handles current format with a single starting date", {
  result   <- handle_date_input(list(value = "12.03.2026", isRange = FALSE), "date")
  expected <- list(date.start = "12.03.2026", date.end = NA)
  expect_identical(result, expected)
})

test_that("handles current format date range", {
  result <- handle_date_input(
    list(value = "19.08.2017", endValue = "20.08.2017", isRange = TRUE),
    "date"
  )
  expected <- list(date.start = "19.08.2017", date.end = "20.08.2017")
  expect_identical(result, expected)
})

test_that("handles current format date range without start", {
  result <- handle_date_input(
    list(endValue = "20.08.2017", isRange = TRUE),
    "date"
  )
  expected <- list(date.start = NA, date.end = "20.08.2017")
  expect_identical(result, expected)
})

test_that("handles date range with time component", {
  result <- handle_date_input(
    list(value = "19.08.2017 17:25", endValue = "20.08.2017 11:09", isRange = TRUE),
    "date"
  )
  expected <- list(date.start = "19.08.2017 17:25", date.end = "20.08.2017 11:09")
  expect_identical(result, expected)
})

test_that("handles year-only date", {
  result   <- handle_date_input(list(value = "2025", isRange = FALSE), "date")
  expected <- list(date.start = "2025", date.end = NA)
  expect_identical(result, expected)
})

test_that("handles month/year date", {
  result   <- handle_date_input(list(value = "03.2026", isRange = FALSE), "date")
  expected <- list(date.start = "03.2026", date.end = NA)
  expect_identical(result, expected)
})

test_that("names output after the supplied field name", {
  result <- handle_date_input(list(value = "2025", isRange = FALSE), "restorationDate")
  expect_named(result, c("restorationDate.start", "restorationDate.end"))
})

test_that("date.end is NA when isRange is FALSE", {
  result <- handle_date_input(list(value = "12.03.2026", isRange = FALSE), "date")
  expect_true(is.na(result$date.end))
})

test_that("date.end is NA when isRange is missing", {
  # isTRUE(NULL) is FALSE, so a missing isRange should produce NA for end.
  result <- handle_date_input(list(value = "12.03.2026"), "date")
  expect_true(is.na(result$date.end))
})

test_that("returns a warning and NA list for unexpected input", {
  expect_warning(result <- handle_date_input(42L, "date"))
  expect_true(is.na(result$date.start))
  expect_true(is.na(result$date.end))
})

test_that("date strings are not modified", {
  # No parsing, formatting, or type conversion should occur.
  input  <- "19.08.2017 17:25"
  result <- handle_date_input(input, "date")
  expect_identical(result$date.start, input)
})


# ---- handle_legacy_date_range_fields() ----------------------------------------------

test_that("normalises beginningDate and endDate to date.start and date.end", {
  resource <- list(
    identifier    = "legacyDateRangeResource",
    category      = "Feature",
    beginningDate = "12.03.2026",
    endDate       = "13.03.2026"
  )
  result   <- handle_legacy_date_range_fields(resource)
  expected <- list(
    identifier = "legacyDateRangeResource",
    category   = "Feature",
    date = list(value = "12.03.2026", isRange = TRUE, endValue = "13.03.2026")
  )
  expect_identical(result, expected)
})

test_that("removes beginningDate and endDate from the resource", {
  resource <- list(
    identifier    = "legacyDateRangeResource",
    category      = "Feature",
    beginningDate = "12.03.2026",
    endDate       = "13.03.2026"
  )
  result <- handle_legacy_date_range_fields(resource)
  expect_false("beginningDate" %in% names(result))
  expect_false("endDate" %in% names(result))
  expect_true("date" %in% names(result))
})

test_that("sets date.end to NA if only beginningDate is present", {
  resource <- list(identifier = "onlyBegin", beginningDate = "12.03.2026")
  result   <- handle_legacy_date_range_fields(resource)
  expect_equal(result$date$value, "12.03.2026")
  expect_false(result$date$isRange)
})

test_that("sets date$value to NA if only endDate is present", {
  resource <- list(identifier = "onlyEnd", endDate = "13.03.2026")
  result   <- handle_legacy_date_range_fields(resource)
  expect_true(is.na(result$date$value))
  expect_equal(result$date$endValue, "13.03.2026")
})

test_that("returns resource unchanged if no legacy date fields present", {
  resource <- list(identifier = "modernResource", category = "Find")
  result   <- handle_legacy_date_range_fields(resource)
  expect_identical(result, resource)
})

test_that("does not affect other fields in the resource", {
  resource <- list(
    identifier    = "legacyResource",
    category      = "Feature",
    processor     = "Anna",
    beginningDate = "12.03.2026",
    endDate       = "13.03.2026"
  )
  result <- handle_legacy_date_range_fields(resource)
  expect_equal(result$identifier, "legacyResource")
  expect_equal(result$category,   "Feature")
  expect_equal(result$processor,  "Anna")
})
