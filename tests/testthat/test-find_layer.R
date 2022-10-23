source(file = "../load_testdata.R")

uidlist <- get_uid_list(test_docs)

proj_in <- which(uidlist$type == "Project")

pottery_in <- which(uidlist$type == "Pottery")

test_that("returns na for project", {
  expect_identical(find_layer(resource = test_resources[[proj_in]],
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
