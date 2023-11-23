skip_on_cran()

connection <- skip_if_no_connection()

check <- idf_last_changed(connection = connection, n = 5)
if (all(is.na(check))) {
  skip("Test skipped, no changes recorded in 'rtest'-project database in this docker.")
}

test_that("message & NA on non-existing changes", {
  connection$project <- "empty-db"
  expect_message(res <- idf_last_changed(connection = connection), "_changes")
  expect_true(is.na(res))
})

index <- get_field_index(connection)

test_that("returns a character vector of length n", {
  n <- 5
  res <- idf_last_changed(connection = connection, n = n)
  expect_equal(class(res), "character")
  expect_length(res, n)
})

test_that("returns a character vector of
          length nrow(index)+1 (no config in index)
          when n = 'all' or n = Inf", {
  n <- "all"
  res <- idf_last_changed(connection = connection, n = n)
  expect_equal(class(res), "character")
  if ("configuration" %in% res) {
    expect_length(res, nrow(index)+1)
  } else {
    expect_length(res, nrow(index))
  }

  n <- Inf
  res <- idf_last_changed(connection = connection, n = n)
  expect_equal(class(res), "character")
  if ("configuration" %in% res) {
    expect_length(res, nrow(index)+1)
  } else {
    expect_length(res, nrow(index))
  }
})

test_that("error if n is not numeric (and not Inf/all)", {
  n <- "börek"
  expect_error(idf_last_changed(connection = connection, n = n),
               "is.numeric")
})

test_that("returns UUIDs when no index available", {
  n <- 10
  res <- idf_last_changed(connection = connection, n = n)
  check <- check_if_uid(res)
  exception <- c("project", "configuration")
  exception <- which(res %in% exception)
  expect_true(all(check[-exception]))
})

test_that("returns no UUIDs when index available", {
  n <- 100
  res <- idf_last_changed(connection = connection,
                          index = index,
                          n = n)
  check <- check_if_uid(res)
  exception <- c("project", "configuration")
  exception <- which(res %in% exception)
  if (length(exception) == 0) {
    expect_false(all(check))
  } else {
    expect_false(all(check[-exception]))
  }
})

test_that("returns UUIDs + warning when index is wrong", {
  no_index <- "börek"
  expect_warning(res <- idf_last_changed(connection = connection,
                          index = no_index,
                          n = 5), "index")
  check <- check_if_uid(res)
  exception <- c("project", "configuration")
  exception <- which(res %in% exception)
  expect_true(all(check[-exception]))
})

test_that("returns UUIDs + warning when index is wrong", {
  no_index <- index
  colnames(no_index) <- c("category", "börek", "identifier", "isRecordedIn", "liesWithin")
  expect_warning(res <- idf_last_changed(connection = connection,
                                         index = no_index,
                                         n = 5), "index")
  check <- check_if_uid(res)
  exception <- c("project", "configuration")
  exception <- which(res %in% exception)
  expect_true(all(check[-exception]))
})

test_that("error if connection settings dont have project", {
  connection$project <- NULL
  expect_error(idf_last_changed(connection = connection, n = 5),
               "project")
})
