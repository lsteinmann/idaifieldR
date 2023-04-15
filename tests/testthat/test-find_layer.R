source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

proj_in <- which(uidlist$category == "Project")

test_that("returns na for project", {
  expect_identical(find_layer(id = test_resources[[proj_in]]$identifier,
                              id_type = "identifier",
                              uidlist = uidlist),
                   NA)
})

test_that("returns na without uidlist", {
  expect_warning(test <- find_layer(id = uidlist$identifier[5],
                                    id_type = "identifier",
                                    uidlist = NULL),
                   "uidlist")
  expect_identical(test, NA)
})

test_that("returns layer for inscription in coin", {
  expect_identical(find_layer(id = "Befund_1_InschriftAufMünze",
                              id_type = "identifier",
                              uidlist = uidlist),
                   "Befund_1")
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
  expect_identical(find_layer(id = "d95e59f3-1440-46fd-9e71-5835b2b888d0",
                              id_type = "UID",
                              uidlist = uuids),
                   "b6014881-d8b7-2bb6-b5df-73245374e791")
})



