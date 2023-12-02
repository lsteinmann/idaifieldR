source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)


test_that("renames type to category", {
  resource <- test_resources[[5]]
  resource$category <- "TEST"
  resource$category <- NULL
  test <- simplify_single_resource(resource = resource,
                                   find_layers = FALSE,
                                   replace_uids = FALSE)
  expect_false(any(names(test) == "type"))
  expect_identical(test$category, resource$type)
})

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

item <- match("Testformular", uidlist$category)

test_that("removes configname from category", {
  test <- simplify_single_resource(test_resources[[item]],
                                   uidlist = uidlist,
                                   keep_geometry = TRUE)
  expect_false(grepl(":", test$category))
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


test_that("keeps names", {
  expect_identical(names(test_resources),
                   names(simplify_idaifield(test_resources,
                                            replace_uids = TRUE)))
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

  test_that("fail without uidlist when replace_uids = TRUE", {
    expect_error(simplify_single_resource(test_resources[[item]],
                                          replace_uids = TRUE,
                                          find_layers = FALSE,
                                          uidlist = NULL))
  })

  test_that("warning without uidlist when find_layers = TRUE", {
    expect_warning(simplify_single_resource(test_resources[[item]],
                                          replace_uids = FALSE,
                                          find_layers = TRUE,
                                          uidlist = NULL))
  })

  test_that("pass without uidlist when replace_uids = FALSE", {
    test <- simplify_single_resource(test_resources[[item]],
                                     replace_uids = FALSE,
                                     find_layer = FALSE,
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

suppressMessages(simple <- simplify_idaifield(test_docs))


test_that("attaches attribute for duplicate names", {
  expect_contains(names(attributes(simple)), "duplicate_names")
})

test_that("contains no special config names in columns", {
  expect_false(any(grepl(":", names(simple))))
})

test_that("returns same object if already simple", {
  simple1 <- simplify_idaifield(simple)
  expect_identical(simple, simple1)
})



conn <- skip_if_no_connection()

projs <- try(idf_projects(conn), silent = TRUE)

if (!"idaifieldr-demo" %in% projs) {
  skip("Needs project db 'idaifieldr-demo'")
}

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

test_that("notify for unavailable language", {
  lang <- "tr"
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





test_that("colnames from checkboxes are spread", {
  test_simple <- simplify_idaifield(test_resources,
                                    keep_geometry = TRUE,
                                    replace_uids = TRUE)
  namesvec <- unique(unlist(lapply(test_simple, names)))
  namesvec <- namesvec[grepl("testAnkreuzfeld", namesvec)]
  expect_gt(length(namesvec), 1)
})


test_that("colnames from checkboxes are NOT spread", {
  test_simple <- simplify_idaifield(test_resources,
                                    keep_geometry = TRUE,
                                    replace_uids = TRUE,
                                    spread_fields = FALSE)
  namesvec <- unique(unlist(lapply(test_simple, names)))
  namesvec <- namesvec[grepl("testAnkreuzfeld", namesvec)]
  expect_equal(length(namesvec), 1)
})
