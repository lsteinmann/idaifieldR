test_that("fails", {
  expect_error(test <- suppressWarnings(idf_projects(NA)))
})

skip_on_cran()
conn <- skip_if_no_connection()


test_that("returns character vector", {
  expect_type(idf_projects(conn), "character")
})

test_that("returns more than 1 project", {
  expect_gt(length(idf_projects(conn)), 1)
})

test_that("removes '_replicator' ", {
  expect_false("_replicator" %in% idf_projects(conn))
})

test_that("error when status = false", {
  conn$status <- FALSE
  expect_error(idf_projects(conn))
})

