source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

item <- grep("meas_dimTest", uidlist$identifier)
names <- uidlist$identifier[item]

names

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
  expect_true(grepl("mean", names(dimlist)))
})


test_that("calculates mean", {
  resource <- test_resources[[which(uidlist$identifier == "MOLLUSK_m_range_dimTest")]]
  dimlist <- idf_sepdim(resource$dimensionLength)
  #  TODO it does not currently do that
  expect_true(grepl("mean", names(dimlist)))
})
