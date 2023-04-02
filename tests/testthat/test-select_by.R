source(file = "../load_testdata.R")


test_that("returns resource object", {
  expect_identical(class(select_by(test_docs, by = "category",
                                   value = "Pottery")),
                   "idaifield_resources")
})

test_that("returns less elements", {
  expect_lt(length(select_by(test_docs, by = "category",
                             value = "Pottery")),
            length(test_docs))
})

test_that("returns correct amount of elements", {
  selection <- "Pottery"
  expect_equal(length(select_by(test_docs, by = "category",
                                value = selection)),
               length(which(get_uid_list(test_docs)$category == selection)))
})

test_that("works with multiple values", {
  expect_lt(length(select_by(test_docs, by = "category",
                             value = c("Pottery", "Layer"))),
            length(test_docs))
})


selection <- "Layer"
layers <- select_by(test_docs, by = "category", value = selection)

items <- sample(seq_along(layers), size = 5)

for (item in items) {
  test_that("selection is true", {
    expect_identical(layers[[item]]$category, selection)
  })


  test_that("message when more than one value in by", {
    expect_message(select_by(test_resources,
                             by = c("category", "isRecordedIn"),
                             value = "Pottery"))
  })


  test_that("fails without value", {
    expect_error(select_by(test_resources,
                           by = "category"))
  })
}


test_that("attaches correct names", {
  sel <- select_by(test_docs, by = "category",
                   value = "Pottery")
  expect_identical(names(sel),
                   unlist(lapply(sel, function(x) x$identifier),
                          use.names = FALSE))
})


test_that("attaches attributes", {
  sel_att <- attributes(select_by(test_docs, by = "category",
                       value = "Pottery"))

  expect_true(all(c("connection", "projectname", "config") %in% names(sel_att)))
})

test_that("attaches correct attributes", {
  sel_att <- attributes(select_by(test_docs, by = "category",
                                  value = "Pottery"))
  expect_identical(sel_att$projectname, attr(test_docs, "projectname"))
})


