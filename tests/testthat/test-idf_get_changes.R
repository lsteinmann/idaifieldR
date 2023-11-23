skip_on_cran()

skip_on_ci()

connection <- skip_if_no_connection()

check <- try(idf_last_changed(connection = connection, n = 5))
if (all(is.na(check))) {
  skip("Test skipped, no changes recorded in 'rtest'-project database in this docker.")
} else if (inherits(check, "try-error")) {
  skip(paste0("Test skipped, because of error: ", check))
}

index <- get_field_index(connection)

test_that("returns appropriate (number of) resources for UUID", {
  n <- 5
  rows <- sample(seq_len(nrow(index)), n)
  res <- idf_get_changes(connection = connection, ids = index$UID[rows])
  expect_length(unique(res$identifier), n)
  expect_contains(res$identifier, index$identifier[rows])
})


test_that("returns appropriate (number of) resources for identifier", {
  n <- 5
  rows <- sample(seq_len(nrow(index)), n)
  res <- idf_get_changes(connection = connection, ids = index$identifier[rows])
  expect_length(unique(res$identifier), n)
  expect_contains(res$identifier, index$identifier[rows])
})

test_that("same result for UUID / identifier", {
  n <- 5
  rows <- sample(seq_len(nrow(index)), n)
  res_uid <- idf_get_changes(connection = connection,
                             ids = index$UID[rows])
  res_identifier <- idf_get_changes(connection = connection,
                                    ids = index$identifier[rows])
  expect_equal(res_uid, res_identifier)
})

test_that("date is some form of date", {
  res <- idf_get_changes(connection = connection, ids = index$UID[1:5])$date
  expect_true(inherits(res, "POSIXct"))
})

test_that("date is some form of date", {
  res <- idf_get_changes(connection = connection, ids = index$UID[1:5])
  expect_contains(res$action, c("created", "modified"))
})

test_that("colnames are as expected", {
  n <- 10
  rows <- sample(seq_len(nrow(index)), n)
  res <- idf_get_changes(connection = connection, ids = index$identifier[rows])
  expect_contains(colnames(res), c("identifier", "user", "date", "action"))
})
test_that("colnames are as expected when empty", {
  res <- suppressWarnings(idf_get_changes(connection = connection,
                                          ids = "börek"))
  expect_contains(colnames(res), c("identifier", "user", "date", "action"))
})

test_that("warning when ids dont exist", {
  expect_warning(idf_get_changes(connection = connection,
                  ids = "börek"), "resources")
})

test_that("empty when no ids exist", {
  res <- suppressWarnings(idf_get_changes(connection = connection,
                                          ids = "börek"))
  expect_equal(nrow(res), 0)
})

test_that("works with project", {
  res <- idf_get_changes(connection = connection,
                         ids = "project")
  expect_equal(unique(res$identifier), connection$project)
})

test_that("works with configuration", {
  res <- idf_get_changes(connection = connection,
                         ids = "configuration")
  expect_equal(unique(res$identifier), "Configuration")
})
