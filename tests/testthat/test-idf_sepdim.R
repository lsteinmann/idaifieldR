source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

test_that("leaves cm as cm", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_cm_meas_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionHeight)
  expect_equal(dimlist$dimensionLength_cm_1, 2)
})

test_that("converts mm to cm", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_mm_meas_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionHeight)
  expect_equal(dimlist$dimensionLength_cm_1, 2)
})

test_that("converts m to cm", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_m_meas_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionHeight)
  expect_equal(dimlist$dimensionLength_cm_1, 2)
})

test_that("puts mean in name", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_m_range_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionLength)
  expect_true(any(grepl("mean", names(dimlist))))
})

test_that("calculates mean (data is range of 1m and 2m)", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_m_range_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionLength)
  expect_equal(dimlist$dimensionLength_cm_mean_1, 150)
})
