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

item <- sample(length(layers), 1)

test_that("selection is true", {
  expect_identical(layers[[item]]$type, selection)
})
