test_that("check_if_uid identifies UID", {
  expect_true(check_if_uid(string = "0324141a-8201-c5dc-631b-4dded4552ac4"))
})

test_that("check_if_uid refuses non-UID", {
  expect_false(check_if_uid(string = "börek"))
})

test_that("check_if_uid identifies UIDs in vector", {
  expect_true(check_if_uid(string = c("0324141a-8201-c5dc-631b-4dded4552ac4",
                                      "185d08b6-b9a5-7464-9e44-ecf2fe29bc36",
                                      2))[1])
  expect_true(check_if_uid(string = c("0324141a-8201-c5dc-631b-4dded4552ac4",
                                      "185d08b6-b9a5-7464-9e44-ecf2fe29bc36",
                                      2))[2])
  expect_false(check_if_uid(string = c("0324141a-8201-c5dc-631b-4dded4552ac4",
                                       "185d08b6-b9a5-7464-9e44-ecf2fe29bc36",
                                       2))[3])
})
