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
                 "Keramik mit Punkt 1", "Keramik mit Multipunkt",
                 "Ziegel Polygon mit Höhen", "Keramik mit Punkt und Höhe")
uidlist <- get_uid_list(test_docs)
index <- match(testobjekte, uidlist$identifier)
names(index) <- testobjekte
rm(testobjekte)

## Polygone
testdata <- test_resources[[index["Terrakotta mit Polygon"]]]$geometry
test_that("returns 'polygon' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "Polygon")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns only one matrix (for one polygon)", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
})

testdata <- test_resources[[index["Keramik mit Multipolygon"]]]$geometry
test_that("returns 'polygon' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "MultiPolygon")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns two polygons", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 2)
})
test_that("returns a matrix", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[2]]))
})

### Lines
testdata <- test_resources[[index["Knochen mit Line"]]]$geometry
test_that("returns 'LineString' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "LineString")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns one line / matrix", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 1)
})
test_that("returns a matrix with two sets of coords", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[1]]), 2)
})
testdata <- test_resources[[index["Knochen mit Polyline"]]]$geometry
test_that("returns 'LineString' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "LineString")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns one line / matrix", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
})
test_that("has four sets of coordinates", {
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[1]]), 4)
})
testdata <- test_resources[[index["Knochen mit MultiLine"]]]$geometry
test_that("returns 'MultiLineString' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "MultiLineString")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns two lines/matrices", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 2)
})
test_that("returns a matrix with 2 sets of coords each", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[2]]))
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[1]]), 2)
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[2]]), 2)
})

## Points
testdata <- test_resources[[index["Keramik mit Punkt 1"]]]$geometry
test_that("returns 'Point' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "Point")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns one point / matrix", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 1)
})
test_that("returns a matrix", {
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
})
test_that("has one set of coordinates", {
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[1]]), 1)
})
testdata <- test_resources[[index["Keramik mit Multipunkt"]]]$geometry
test_that("returns 'MultiPoint' in type list", {
  expect_identical(reformat_geometry(testdata)$type, "MultiPoint")
})
test_that("returns a list", {
  expect_type(reformat_geometry(testdata)$coordinates, "list")
})
test_that("returns one matrix", {
  expect_equal(length(reformat_geometry(testdata)$coordinates), 1)
  expect_true(is.matrix(reformat_geometry(testdata)$coordinates[[1]]))
})
test_that("has three sets of coordinates", {
  expect_equal(nrow(reformat_geometry(testdata)$coordinates[[1]]), 3)
})


## height values
testdata <- test_resources[[index["Ziegel Polygon mit Höhen"]]]$geometry
test_that("keeps height values", {
  expect_equal(reformat_geometry(testdata)$coordinates[[1]][,3],
               c(10, 11, 12, 13))
})
testdata <- test_resources[[index["Knochen mit Polyline"]]]$geometry
test_that("adds zero for height values", {
  expect_equal(reformat_geometry(testdata)$coordinates[[1]][,3],
               c(0, 0, 0, 0))
})

testdata <- test_resources[[index["Keramik mit Punkt und Höhe"]]]$geometry
test_that("keeps height values", {
  expect_equal(reformat_geometry(testdata)$coordinates[[1]][,3],
               10)
})

multipoly <- list(type = "MultiPolygon",
                  coordinates = list(
                    list(list(list(523593L, 4153416L),
                              list(523708L, 4153395L),
                              list(523692L, 4153288L),
                              list(523556L, 4153325L))),
                    list(list(list(523435L, 4153402L),
                              list(523603L, 4153376L),
                              list(523642L, 4153480L),
                              list(523503L, 4153475L))),
                    list(list(list(523435L, 4153402L),
                              list(523603L, 4153376L),
                              list(523642L, 4153480L),
                              list(523503L, 4153475L)))))

test_that("processes multipolygon", {
  res <- reformat_geometry(multipoly)
  expect_equal(length(res$coordinates), length(multipoly$coordinates))
  expect_equal(unlist(lapply(res$coordinates, length)), c(12, 12, 12))
})

