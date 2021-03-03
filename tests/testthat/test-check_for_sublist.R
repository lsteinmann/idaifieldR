test_resource <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                     package = "idaifieldR"))

list <- list(1, 2, 3, 4)

test_that("check_for_sublist can process a list", {
  expect_true(check_for_sublist(list))
})

list <- list(list, 1, 2, 3)

test_that("check_for_sublist identifies sublists", {
  expect_true(check_for_sublist(list))
})

list <- list(list, "börek")

test_that("check_for_sublist identifies sublists", {
  expect_true(check_for_sublist(list))
})
