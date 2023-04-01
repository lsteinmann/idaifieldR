

dat_list <- list(type = "range",
                 begin = list(inputYear = -2000, inputType = "bce"),
                 end = list(inputYear = -2000, inputType = "ce"))
test_that("converts to abs", {
  test <- fix_dating(list(dat_list))
  expect_equal(test$dating.max, 2000)
})


dat_list <- list(type = "range",
                 begin = list(inputYear = 2000, inputType = "bce"),
                 end = list(inputYear = 2000, inputType = "ce"))


test_that("returns correct number of elements", {
  test <- fix_dating(list(dat_list))
  expect_equal(length(test), 6)
})

test_that("negative number for bce, positive for ce", {
  test <- fix_dating(list(dat_list))
  expect_equal(test$dating.min, -2000)
  expect_equal(test$dating.max, 2000)
})

dat_list_sec <- list(type = "exact",
                     end = list(inputYear = 1234, inputType = "ce"))

test_that("prefers exact dating", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_equal(test$dating.min, 1234)
  expect_equal(test$dating.max, 1234)
})

dat_list <- list(type = "before",
                 end = list(inputYear = 100, inputType = "bce"))
dat_list_sec <- list(type = "after",
                     begin = list(inputYear = 200, inputType = "bce"))

test_that("before/after", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_equal(test$dating.min, -200)
  expect_equal(test$dating.max, -100)
})

dat_list <- list(type = "range",
                 begin = list(inputYear = 100, inputType = "bce"),
                 end = list(inputYear = 100, inputType = "ce"))
dat_list_sec <- list(type = "range",
                     begin = list(inputYear = 150, inputType = "bce"),
                     end = list(inputYear = 50, inputType = "ce"))

test_that("picks min/max from ranges", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_equal(test$dating.min, -150)
  expect_equal(test$dating.max, 100)
})




test_that("type = multiple", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_identical(test$dating.type, "multiple")
})

test_that("complete pastes info", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_match(test$dating.complete, "dating list 1:")
  expect_match(test$dating.complete, ";")
})

dat_list <- list(type = "range",
                 begin = list(inputYear = 2000, inputType = "bce"),
                 end = list(inputYear = 2000, inputType = "ce"),
                 isUncertain = TRUE)
dat_list_sec <- list(type = "exact",
                     end = list(inputYear = 1234, inputType = "ce"),
                     isUncertain = TRUE)
test_that("uncertain = TRUE", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_true(test$dating.uncertain)
})

dat_list <- list(type = "range",
                 begin = list(inputYear = 2000, inputType = "bce"),
                 end = list(inputYear = 2000, inputType = "ce"),
                 isUncertain = FALSE)
dat_list_sec <- list(type = "exact",
                     end = list(inputYear = 1234, inputType = "ce"),
                     isUncertain = TRUE)
test_that("uncertain = TRUE", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_true(test$dating.uncertain)
})

dat_list <- list(type = "range",
                 begin = list(inputYear = 2000, inputType = "bce"),
                 end = list(inputYear = 2000, inputType = "ce"),
                 isUncertain = FALSE)
dat_list_sec <- list(type = "exact",
                     end = list(inputYear = 1234, inputType = "ce"),
                     isUncertain = FALSE)
test_that("uncertain = FALSE", {
  test <- fix_dating(list(dat_list, dat_list_sec))
  expect_false(test$dating.uncertain)
})

test_that("NA if no list", {
  expect_message(fix_dating(37), "list")
  expect_true(is.na(fix_dating(37)))
})

