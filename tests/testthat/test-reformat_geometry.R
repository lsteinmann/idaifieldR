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

testobjekte <- c("Terrakotta mit Polygon", "Keramik mit Multipolygon",
                 "Knochen mit Line", "Knochen mit Polyline",
                 "Knochen mit MultiLine",
                 "Keramik mit Punkt 1", "Keramik mit Multipunkt")
uidlist <- get_uid_list(test_docs)
index <- match(testobjekte, uidlist$identifier)
names(index) <- testobjekte
rm(testobjekte)

## Polygone
testres <- test_resources[[index["Terrakotta mit Polygon"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'polygon' in type list", {
  expect_identical(testres$type, "Polygon")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns only one matrix (for one polygon)", {
  expect_equal(length(testres$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(testres$coordinates[[1]]))
})

testres <- test_resources[[index["Keramik mit Multipolygon"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'polygon' in type list", {
  expect_identical(testres$type, "MultiPolygon")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns two polygons", {
  expect_equal(length(testres$coordinates), 2)
})
test_that("returns a matrix", {
  expect_true(is.matrix(testres$coordinates[[1]]))
  expect_true(is.matrix(testres$coordinates[[2]]))
})

### Lines
testres <- test_resources[[index["Knochen mit Line"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'LineString' in type list", {
  expect_identical(testres$type, "LineString")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns one line / matrix", {
  expect_equal(length(testres$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(testres$coordinates[[1]]))
})
test_that("has two coordinates", {
  expect_equal(nrow(testres$coordinates[[1]]), 2)
})
testres <- test_resources[[index["Knochen mit Polyline"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'LineString' in type list", {
  expect_identical(testres$type, "LineString")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns one line / matrix", {
  expect_equal(length(testres$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(testres$coordinates[[1]]))
})
test_that("has four coordinates", {
  expect_equal(nrow(testres$coordinates[[1]]), 4)
})
testres <- test_resources[[index["Knochen mit MultiLine"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'MultiLineString' in type list", {
  expect_identical(testres$type, "MultiLineString")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns two lines/matrices", {
  expect_equal(length(testres$coordinates), 2)
})
test_that("returns a matrix each", {
  expect_true(is.matrix(testres$coordinates[[1]]))
  expect_true(is.matrix(testres$coordinates[[2]]))
})
test_that("has 2 coordinates each", {
  expect_equal(nrow(testres$coordinates[[1]]), 2)
  expect_equal(nrow(testres$coordinates[[2]]), 2)
})

## Points
testres <- test_resources[[index["Keramik mit Punkt 1"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'Point' in type list", {
  expect_identical(testres$type, "Point")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns one point / matrix", {
  expect_equal(length(testres$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(testres$coordinates[[1]]))
})
test_that("has one set of coordinates", {
  expect_equal(nrow(testres$coordinates[[1]]), 1)
})
testres <- test_resources[[index["Keramik mit Multipunkt"]]]$geometry
testres <- reformat_geometry(testres)
test_that("returns 'MultiPoint' in type list", {
  expect_identical(testres$type, "MultiPoint")
})
test_that("returns a list", {
  expect_type(testres$coordinates, "list")
})
test_that("returns three points/matrices", {
  expect_equal(length(testres$coordinates), 3)
})
test_that("returns a matrix each", {
  expect_true(is.matrix(testres$coordinates[[1]]))
  expect_true(is.matrix(testres$coordinates[[2]]))
  expect_true(is.matrix(testres$coordinates[[3]]))
})
test_that("has one set of coordinates each", {
  expect_equal(nrow(testres$coordinates[[1]]), 1)
  expect_equal(nrow(testres$coordinates[[2]]), 1)
  expect_equal(nrow(testres$coordinates[[3]]), 1)
})
