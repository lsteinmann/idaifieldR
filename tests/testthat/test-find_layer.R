source(file = "../load_testdata.R")

index <- make_index(test_docs)
proj_id <- index$identifier[index$category == "Project"]
layer_categories = c("Feature", names(config$categories$Feature$trees))

test_that("returns na for project", {
  expect_identical(find_layer(ids = proj_id,
                              layer_categories = layer_categories,
                              index = index),
                   NA)
})

test_that("returns na without index", {
  ids <- index$identifier[5:10]
  expect_warning(test <- find_layer(ids = ids, index = NULL),
                 "index")
  expect_identical(test, rep(NA, length(ids)))
})

test_that("returns layer for inscription in coin with single id", {
  expect_identical(
    unname(find_layer(ids = "Befund_1_InschriftAufMünze",
                      layer_categories = layer_categories,
                      index = index)),
    "Befund_1"
  )
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
  expect_identical(
    unname(find_layer(uuids$UID,
                      layer_categories = layer_categories,
                      index = uuids)),
    c(
      "b6014881-d8b7-2bb6-b5df-73245374e791",
      NA,
      "b6014881-d8b7-2bb6-b5df-73245374e791"
    )
  )
})


test_that("attaches names", {
  expect_identical(
    names(find_layer(uuids$UID,
                     layer_categories = layer_categories,
                     index = uuids)),
    c("2ab1de16-eddb-0737-79ea-299b0c3a0d06",
      "b6014881-d8b7-2bb6-b5df-73245374e791",
      "d95e59f3-1440-46fd-9e71-5835b2b888d0")
  )
})
