source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

proj_in <- which(uidlist$type == "Project")
config_in <- which(uidlist$UID == "configuration")

pottery_in <- which(uidlist$type == "Pottery")

test_resources <- lapply(test_resources, function(x) fix_relations(x, replace_uids = TRUE,
                                                                   uidlist = uidlist))

test_that("returns na for project/config", {
  expect_identical(find_layer(resource = test_resources[[proj_in]],
                              uidlist = uidlist),
                   NA)
  expect_identical(find_layer(resource = test_resources[[config_in]],
                              uidlist = uidlist),
                   NA)
})

test_that("returns na without uidlist", {
  expect_warning(find_layer(resource = test_resources[[pottery_in[5]]],
                              uidlist = NULL),
                   "uidlist")
  test <- suppressWarnings(find_layer(resource = test_resources[[pottery_in[5]]],
                                      uidlist = NULL))
  expect_identical(test, NA)
})

which(uidlist$identifier == "Befund_1_InschriftAufMünze")

test_that("returns layer for inscription in coin", {
  index <- which(uidlist$identifier == "Befund_1_InschriftAufMünze")
  expect_identical(find_layer(resource = test_resources[[index]],
                            uidlist = uidlist),
                   "Befund_1")
})


for (i in sample(pottery_in, size = 10)) {
  if (is.null(test_resources[[i]]$relations$liesWithin)) {
    next
  } else {
    test_that("returns chr when resource lies within layer", {
      resource <- fix_relations(test_resources[[i]],
                                replace_uids = TRUE,
                                uidlist = uidlist)
      layer <- find_layer(resource = resource,
                          uidlist = uidlist,
                          strict = FALSE)
      expect_type(layer,
                  "character")
    })
  }
}
