source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

item <- which(uidlist$identifier == "Keramik mit Multipolygon")

test_that("geometry is gone", {
  test <- simplify_single_resource(test_resources[[item]],
                                   uidlist = uidlist,
                                   keep_geometry = FALSE)
  expect_null(test$geometry)
})

test_that("geometry is matrix", {
  test <- simplify_single_resource(test_resources[[item]],
                                   uidlist = uidlist,
                                   keep_geometry = TRUE)
  test <- test$geometry
  expect_true("matrix" %in% class(test$coordinates[[1]]))
})

item <- match("Testformular", uidlist$type)

test_that("removes configname from type", {
  test <- simplify_single_resource(test_resources[[item]],
                                   uidlist = uidlist,
                                   keep_geometry = TRUE)
  expect_false(grepl(":", test$type))
})

test_that("removes configname from field", {
  test <- simplify_single_resource(test_resources[[item]],
                                   uidlist = uidlist,
                                   keep_geometry = TRUE)
  expect_false(any(grepl(":", names(test))))
})

test_that("dimensions are spread", {
  test_simple <- simplify_idaifield(test_resources,
                                    keep_geometry = TRUE,
                                    replace_uids = TRUE)
  names <- unique(unlist(lapply(test_simple, names)))
  names <- names[grepl("dimension", names)]
  expect_true(any(grepl("_cm", names)))
})


#mat <- idaifield_as_matrix(test_simple)
#colnames(mat)

items <- sample(seq_along(test_resources), size = 5)
for (item in items) {
#  print(paste("--------------------------###### Nr.: ", item))

  test_that("error when no identifier", {
    test_resources[[item]]$identifier <- NULL
    expect_error(simplify_single_resource(test_resources[[item]]),
                 "valid")
  })

  test_that("fail without uidlist when replaceuid = T", {
    expect_error(simplify_single_resource(test_resources[[item]],
                                          replace_uids = TRUE,
                                          uidlist = NULL))
  })

  test_that("pass without uidlist when replaceuid = F", {
    test <- simplify_single_resource(test_resources[[item]],
                                     replace_uids = FALSE,
                                     uidlist = NULL)
    expect_identical(class(test), "list")
  })

  if (!is.null(test_resources[[item]]$dimensionLength)) {
    test_that("dimension is replaced", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist)
      expect_true(any(grepl("cm", names(test))))
    })
  }

  if (!is.null(test_resources[[item]]$dimensionThickness)) {
    test_that("dimension is replaced", {
      test <- simplify_single_resource(test_resources[[item]],
                                       uidlist = uidlist)
      expect_true(any(grepl("cm", names(test))))
    })
  }
}

test_that("runs without uidlist", {
  expect_s3_class(simplify_idaifield(test_docs), "idaifield_simple")
})

simple <- simplify_idaifield(test_docs)

test_that("contains no special config names in columns", {
  expect_false(any(grepl(":", names(simple))))
})

test_that("returns same object if already simple", {
  simple1 <- simplify_idaifield(simple)
  expect_identical(simple, simple1)
})


skip_on_cran()

connection <- connect_idaifield(serverip = "127.0.0.1",
                                user = "R", pwd = "hallo")

tryCatch({
  sofa::ping(connection)
},
error = function(cond) {
  skip("Test skipped, needs DB-connection")
})

test_that("colnames from checkboxes are spread", {
  test_simple <- simplify_idaifield(test_resources,
                                    keep_geometry = TRUE,
                                    replace_uids = TRUE)
  namesvec <- unique(unlist(lapply(test_simple, names)))
  namesvec <- namesvec[grepl("testAnkreuzfeld", namesvec)]
  expect_gt(length(namesvec), 1)
})

# language support
data("idaifieldr_demodata")

test_that("notify for config", {
  expect_warning(simplify_idaifield(idaifieldr_demodata,
                                    uidlist = get_uid_list(idaifieldr_demodata),
                                    keep_geometry = FALSE,
                                    language = "en",
                                    replace_uids = TRUE),
                 "custom")
})


test_that("notify for language", {
  lang <- "de"
  expect_message(suppressWarnings(simplify_idaifield(idaifieldr_demodata,
                                                     uidlist = get_uid_list(idaifieldr_demodata),
                                                     keep_geometry = FALSE,
                                                     language = lang,
                                                     replace_uids = TRUE)),
                 lang)
})

test_that("return correct language", {
  lang <- "de"
  val <- idaifieldr_demodata[[1]]$doc$resource$shortDescription$de
  test <- suppressWarnings(simplify_idaifield(idaifieldr_demodata,
                                              uidlist = get_uid_list(idaifieldr_demodata),
                                              keep_geometry = FALSE,
                                              language = lang,
                                              replace_uids = TRUE))
  expect_identical(test[[1]]$shortDescription, val)
})


test_that("return all languages", {
  lang <- "all"
  expect_message(test <- suppressWarnings(
    simplify_idaifield(idaifieldr_demodata,
                       uidlist = get_uid_list(idaifieldr_demodata),
                       keep_geometry = FALSE,
                       language = lang,
                       replace_uids = TRUE)),
    "all languages")
  expect_true(all(c("en", "de") %in% names(test[[1]]$shortDescription)))
})


