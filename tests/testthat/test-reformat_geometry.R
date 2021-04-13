source(file = "../load_testdata.R")





test_that("handles emptiness", {
  expect_null(reformat_geometry(NULL))
})

items <- sample(seq_along(test_resources), size = 5)

for (i in items) {
  test <- test_resources[[i]]$geometry

  if (!is.null(test)) {
    test_that("returns a list", {
      expect_identical(class(reformat_geometry(test)),
                       "list")
    })

    test_that("returns the type", {
      expect_identical(class(reformat_geometry(test)$type), "character")
    })

    if (test$type == "Polygon") {
      test_that("returns matrix for polygon", {
        matrix <- convert_to_coordmat(test$coordinates)
        grepl <- grepl("matrix", class(matrix))
        expect_true(any(grepl))
      })
    }
  }
}
