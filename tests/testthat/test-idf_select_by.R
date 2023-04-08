source(file = "../load_testdata.R")

test_that("Old function returns warning", {
  expect_warning(select_by(test_docs,
                           by = "category",
                           value = "Pottery"))
})



test_that("returns resource object", {
  expect_identical(class(idf_select_by(test_docs, by = "category",
                                   value = "Pottery")),
                   "idaifield_resources")
})

test_that("returns less elements", {
  expect_lt(length(idf_select_by(test_docs, by = "category",
                             value = "Pottery")),
            length(test_docs))
})

test_that("returns correct amount of elements", {
  selection <- "Pottery"
  expect_equal(length(idf_select_by(test_docs, by = "category",
                                value = selection)),
               length(which(get_uid_list(test_docs)$category == selection)))
})

test_that("works with multiple values", {
  expect_lt(length(idf_select_by(test_docs, by = "category",
                             value = c("Pottery", "Layer"))),
            length(test_docs))
})




test_that("selection is true", {
  selection <- "Layer"
  test <- idf_select_by(test_docs, by = "category", value = selection)
  test <- lapply(test, function(x) x$category)
  test <- unlist(test)
  expect_identical(unique(test), selection)
})

test_that("warning when more than one value in by", {
  expect_warning(idf_select_by(test_resources,
                               by = c("category", "isRecordedIn"),
                               value = "Pottery"))
})

test_that("fails without value", {
  expect_error(idf_select_by(test_resources,
                             by = "category"))
})

test_that("fails without by", {
  expect_error(idf_select_by(test_resources,
                             value = "zonk"))
})

test_that("works for lists", {
  value <- 2021
  check <- lapply(test_resources, function(x) {
    cmp <- unlist(x[["campaign"]])
    value %in% cmp
  })
  check <- unlist(check)
  test <- idf_select_by(test_resources,
                        by = "campaign",
                        value = value)
  expect_equal(sum(check), length(test))
})

test_that("works for lists", {
  value <- "Anna Allgemeinperson"
  check <- lapply(test_resources, function(x) {
    proc <- unlist(x$processor)
    value %in% proc
    })
  check <- unlist(check)
  test <- idf_select_by(test_resources,
                        by = "processor",
                        value = value)
  expect_equal(sum(check), length(test))
})



test_that("attaches correct names", {
  sel <- idf_select_by(test_docs, by = "category", value = "Pottery")
  expect_identical(names(sel),
                   unlist(lapply(sel, function(x) x$identifier),
                          use.names = FALSE))
})

test_that("attaches correct attributes", {
  sel_att <- attributes(idf_select_by(test_docs, by = "category",
                                  value = "Pottery"))
  expect_identical(sel_att$projectname, attr(test_docs, "projectname"))
})


