source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

proj_in <- which(uidlist$category == "Project")

test_that("returns na for project", {
  expect_identical(find_layer(ids = test_resources[[proj_in]]$identifier,
                              uidlist = uidlist),
                   NA)
})


test_that("warnings for deprecated arguments", {
  expect_warning(find_layer(id = test_resources[[proj_in]]$identifier,
                            uidlist = uidlist),
                 "v0.3.4")
  expect_warning(find_layer(ids = test_resources[[proj_in]]$identifier,
                            id_type = "identifier",
                            uidlist = uidlist),
                 "v0.3.4")
})



test_that("returns na without uidlist", {
  ids <- uidlist$identifier[5:10]
  expect_warning(test <- find_layer(ids = ids, uidlist = NULL),
                   "uidlist")
  expect_identical(test, rep(NA, length(ids)))
})

test_that("returns layer for inscription in coin with single id", {
  expect_identical(unname(find_layer(ids = "Befund_1_InschriftAufMünze",
                              uidlist = uidlist)),
                   "Befund_1")
})




test_that("handles complete uidlist", {
  test <- c(
    NA, NA, "Grab_1", "Befund_6", "Befund_6", "Befund_5", NA, "Grab_1", "Grab_1",
    NA, "Grab_1", NA, NA, "Befund_6", NA, NA, "Befund_1", "Befund_6", "Befund_6",
    "Befund_6", NA, "Befund_6", "Befund_6", "Grab_1", "Befund_6", "Befund_6", NA,
    "Befund_5", "Befund_6", "Grab_1", "Befund_6", "Grab_1", "Befund_6", NA,
    "Grab_1", "Befund_6", "Befund_6", "Befund_6", "Befund_6", "Grab_1", NA,
    "Befund_6", "Befund_6", "Befund_6", "Befund_5", NA, "Befund_6", NA,
    "Befund_6", "Befund_5", NA, "Befund_6", NA, NA, "Befund_6", NA, "Befund_6",
    "Befund_6", "Befund_6", "Befund_1", NA, "Befund_6", NA, NA, "Befund_6", NA,
    NA, NA, "Grab_1", "Befund_6", "Befund_6", "Befund_6", NA, NA
  )
  expect_identical(unname(find_layer(ids = uidlist$identifier,
                              uidlist = uidlist)),
                   test)
})

uuids <- data.frame(
  category = c("Coin", "Layer", "Inscription"),
  UID = c(
    "2ab1de16-eddb-0737-79ea-299b0c3a0d06", "b6014881-d8b7-2bb6-b5df-73245374e791",
    "d95e59f3-1440-46fd-9e71-5835b2b888d0"
  ),
  identifier = c("MÜNZE_1", "Befund_1", "Befund_1_InschriftAufMünze"),
  liesWithin = c("b6014881-d8b7-2bb6-b5df-73245374e791", "SE01", "2ab1de16-eddb-0737-79ea-299b0c3a0d06")
)

test_that("returns layer for inscription in coin when using UUIDs", {
  expect_identical(unname(find_layer(uuids$UID,
                              uidlist = uuids)),
                   c("b6014881-d8b7-2bb6-b5df-73245374e791",
                     NA,
                     "b6014881-d8b7-2bb6-b5df-73245374e791"))
})


test_that("attaches names", {
  expect_identical(names(find_layer(uuids$UID,
                              uidlist = uuids)),
                   c("2ab1de16-eddb-0737-79ea-299b0c3a0d06",
                     "b6014881-d8b7-2bb6-b5df-73245374e791",
                     "d95e59f3-1440-46fd-9e71-5835b2b888d0"))
})
