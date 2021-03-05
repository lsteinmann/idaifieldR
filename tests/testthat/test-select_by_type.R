source(file = "../load_testdata.R")


test_that("returns resource object", {
  expect_identical(class(select_by_type(test_resource, "Pottery")),
                   "idaifield_resource")
})

test_that("returns less elements", {
  expect_lt(length(select_by_type(test_resource, "Pottery")),
            length(test_resource))
})


selection <- "Layer"
layers <- select_by_type(test_resource, selection)

item <- sample(length(layers), 1)

test_that("selection is true", {
  expect_identical(layers[[item]]$type, selection)
})
