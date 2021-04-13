source(file = "../load_testdata.R")


test_that("returns resource object", {
  expect_identical(class(select_by(test_docs, by = "type",
                                   value = "Pottery")),
                   "idaifield_resources")
})

test_that("returns less elements", {
  expect_lt(length(select_by(test_docs, by = "type",
                             value = "Pottery")),
            length(test_docs))
})


selection <- "Layer"
layers <- select_by(test_docs, by = "type", value = selection)

items <- sample(seq_along(layers), size = 5)

for (item in items) {
  test_that("selection is true", {
    expect_identical(layers[[item]]$type, selection)
  })


  test_that("message when more than one value in by", {
    expect_message(select_by(test_resources,
                             by = c("type", "isRecordedIn"),
                             value = "Pottery"))
  })


  test_that("fails without value", {
    expect_error(select_by(test_resources,
                           by = "type"))
  })
}


