skip("Needs DB-connection")

test_resource <- get_idaifield_docs(serverip = "192.168.2.21",
                                    projectname = "milet",
                                    user = "R",
                                    pwd = "hallo",
                                    simplified = FALSE)

unnested_test_resource <- get_idaifield_docs(serverip = "192.168.3.21",
                                             projectname = "milet",
                                             user = "R",
                                             pwd = "hallo",
                                             simplified = TRUE)

test_that("returns docs-lists", {
  check <- check_if_idaifield(test_resource)
  expect_identical(unname(check[1, "idaifield_docs"]), TRUE)
})

test_that("returns resource-lists", {
  check <- check_if_idaifield(unnested_test_resource)
  expect_identical(unname(check[1, "idaifield_resource"]), TRUE)
})
