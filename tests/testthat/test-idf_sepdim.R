source(file = "../load_testdata.R")

test_that("cm as cm", {
  resource <- test_resources[["MOLLUSK_cm_meas_dimTest"]]
  dimlist <- idf_sepdim(resource$dimensionHeight, "dimensionHeight")
  expect_equal(dimlist$dimensionHeight_cm_1, 2)
})

test_that("leaves cm as cm", {
  test <- list(list(inputValue = 10, inputUnit = "cm"))
  expect_equal(idf_sepdim(test, name = "test")[[1]], 10)
})

test_that("mm to cm", {
  resource <- test_resources[["MOLLUSK_mm_meas_dimTest"]]
  dimlist <- idf_sepdim(resource$dimensionHeight, "dimensionHeight")
  expect_equal(dimlist$dimensionHeight_cm_1, 2)
})

test_that("mm to cm without value", {
  test <- list(list(inputValue = 10, inputUnit = "mm"))
  expect_equal(idf_sepdim(test, name = "test")[[1]], 1)
})

test_that("m to cm", {
  resource <- test_resources[["MOLLUSK_m_meas_dimTest"]]
  dimlist <- idf_sepdim(resource$dimensionHeight, "dimensionHeight")
  expect_equal(dimlist$dimensionHeight_cm_1, 2)
})

test_that("m to cm", {
  test <- list(list(inputValue = 10, inputUnit = "m"))
  expect_equal(idf_sepdim(test, name = "test")[[1]], 1000)
})

test_that("puts mean in name", {
  resource <- test_resources[["MOLLUSK_m_range_dimTest"]]
  dimlist <- idf_sepdim(resource$dimensionLength, "dimensionLength")
  expect_true(any(grepl("mean", names(dimlist))))
})

test_that("calculates mean (data is range of 1m and 2m)", {
  resource <- test_resources[["MOLLUSK_m_range_dimTest"]]
  dimlist <- idf_sepdim(resource$dimensionLength, "dimensionLength")
  expect_equal(dimlist$dimensionLength_cm_mean_1, 150)
})

test_that("throws error when dimensionList is not a list", {
  expect_error(idf_sepdim(10, "test"), "dimensionList")
  expect_error(idf_sepdim(NA, "test"), "dimensionList")
})

testlist <- list(
  list(
    inputValue = 1,
    measurementPosition = "Maximale Ausdehnung",
    measurementComment = "",
    inputUnit = "m",
    isImprecise = FALSE,
    inputRangeEndValue = 2,
    rangeMin = 1000000,
    rangeMax = 2000000
  ),
  list(
    value = 2000000,
    inputValue = 2,
    measurementPosition = "Maximale Ausdehnung",
    measurementComment = "test",
    inputUnit = "m",
    isImprecise = FALSE
  )
)

test_that("throws error when no name is provided", {
  expect_error(idf_sepdim(testlist), "name")
})

