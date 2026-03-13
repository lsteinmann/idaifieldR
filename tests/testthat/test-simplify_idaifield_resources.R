source(file = "../load_testdata.R")

# --- Minimal self-contained test resources -----------------------------------
# These are used for unit tests that do not need real archaeological data.
# Keeping them here makes each test readable without digging into external files.

minimal_resource <- list(
  identifier = "TestObject-001",
  category = "Find",
  relations = list(
    isRecordedIn = list("aaaaaaaa-0000-0000-0000-000000000001"),
    liesWithin   = list("aaaaaaaa-0000-0000-0000-000000000002")
  )
)

minimal_index <- data.frame(
  identifier = c("Trench-01", "Layer-01"),
  UID        = c("aaaaaaaa-0000-0000-0000-000000000001",
                 "aaaaaaaa-0000-0000-0000-000000000002"),
  stringsAsFactors = FALSE
)

resource_with_geometry <- list(
  identifier = "TestObject-002",
  category   = "Find",
  geometry   = list(
    type        = "Point",
    coordinates = list(28.18, 40.14)
  ),
  relations  = list()
)

resource_legacy_type <- list(
  identifier = "TestObject-003",
  type       = "Find"
  # note: no 'category' field — simulates old iDAI.field format
)


# =============================================================================
# simplify_single_resource()
# =============================================================================

test_that("stops when resource has no identifier", {
  bad_resource <- minimal_resource
  bad_resource$identifier <- NULL
  expect_error(
    simplify_single_resource(bad_resource, replace_uids = FALSE, find_layers = FALSE),
    "valid format"
  )
})

test_that("renames legacy 'type' field to 'category'", {
  result <- simplify_single_resource(
    resource_legacy_type,
    replace_uids = FALSE,
    find_layers  = FALSE
  )
  expect_false("type" %in% names(result))
  expect_equal(result$category, "Find")
})

test_that("relations are flattened with relation. prefix", {
  result <- simplify_single_resource(
    minimal_resource,
    index        = minimal_index,
    replace_uids = FALSE,
    find_layers  = FALSE
  )
  expect_true("relation.isRecordedIn" %in% names(result))
  expect_true("relation.liesWithin" %in% names(result))
  expect_false("relations" %in% names(result))
})

test_that("UUIDs in relations are replaced when replace_uids = TRUE", {
  result <- simplify_single_resource(
    minimal_resource,
    index        = minimal_index,
    replace_uids = TRUE,
    find_layers  = FALSE
  )
  expect_equal(result$relation.isRecordedIn, "Trench-01")
  expect_equal(result$relation.liesWithin, "Layer-01")
})

test_that("UUIDs are kept as-is when replace_uids = FALSE", {
  result <- simplify_single_resource(
    minimal_resource,
    replace_uids = FALSE,
    find_layers  = FALSE
  )
  expect_true(check_if_uid(result$relation.isRecordedIn))
})

test_that("stops when replace_uids = TRUE but no index supplied", {
  expect_error(
    simplify_single_resource(
      minimal_resource,
      index        = NULL,
      replace_uids = TRUE,
      find_layers  = FALSE
    )
  )
})

test_that("geometry is removed when keep_geometry = FALSE", {
  result <- simplify_single_resource(
    resource_with_geometry,
    replace_uids  = FALSE,
    find_layers   = FALSE,
    keep_geometry = FALSE
  )
  expect_null(result$geometry)
})

test_that("geometry is kept as a string when keep_geometry = TRUE", {
  result <- simplify_single_resource(
    resource_with_geometry,
    replace_uids  = FALSE,
    find_layers   = FALSE,
    keep_geometry = TRUE
  )
  expect_true(is.character(result$geometry))
})

test_that("stops when find_layers = TRUE but config is not idaifield_config", {
  expect_error(
    simplify_single_resource(
      minimal_resource,
      index       = minimal_index,
      config      = list(),        # wrong class
      find_layers = TRUE
    ),
    "idaifield_config"
  )
})

test_that("returns a list", {
  result <- simplify_single_resource(
    minimal_resource,
    replace_uids = FALSE,
    find_layers  = FALSE
  )
  expect_true(is.list(result))
})


# =============================================================================
# simplify_idaifield()
# =============================================================================

test_that("returns idaifield_simple class", {
  result <- suppressMessages(simplify_idaifield(test_docs))
  expect_s3_class(result, "idaifield_simple")
})

test_that("returns same object unchanged if already idaifield_simple", {
  simple <- suppressMessages(simplify_idaifield(test_docs))
  result <- suppressMessages(simplify_idaifield(simple))
  expect_identical(simple, result)
})

test_that("stops when input is neither idaifield_docs nor idaifield_resources", {
  expect_error(
    simplify_idaifield(list(a = 1, b = 2)),
    "idaifield_resources"
  )
})

test_that("preserves resource names", {
  result <- suppressMessages(simplify_idaifield(test_docs))
  expect_identical(names(test_docs), names(result))
})

test_that("attaches connection and projectname attributes", {
  result <- suppressMessages(simplify_idaifield(test_docs))
  expect_false(is.null(attr(result, "connection")))
  expect_false(is.null(attr(result, "projectname")))
})

test_that("geometry is absent when keep_geometry = FALSE", {
  result <- suppressMessages(simplify_idaifield(test_docs, keep_geometry = FALSE))
  geometries <- lapply(result, function(x) x$geometry)
  expect_true(all(vapply(geometries, is.null, logical(1))))
})

test_that("geometry is a string when keep_geometry = TRUE", {
  result <- suppressMessages(simplify_idaifield(test_docs, keep_geometry = TRUE))
  geometries <- Filter(Negate(is.null), lapply(result, function(x) x$geometry))
  if (length(geometries) > 0) {
    expect_true(all(vapply(geometries, is.character, logical(1))))
  } else {
    skip("No resources with geometry in test data")
  }
})

test_that("no raw UUIDs remain in relation fields after simplification", {
  result <- suppressMessages(simplify_idaifield(test_docs))
  relation_fields <- lapply(result, function(x) {
    x[grepl("^relation\\.", names(x))]
  })
  all_values <- unlist(relation_fields)
  expect_false(any(check_if_uid(all_values)))
})

test_that("message is shown when no index is supplied", {
  expect_message(
    simplify_idaifield(test_docs),
    "index"
  )
})

test_that("no message when index is supplied", {
  index <- get_uid_list(test_docs)
  expect_no_message(
    simplify_idaifield(test_docs, index = index, config = config)
  )
})

# --- Deprecated parameter warnings -------------------------------------------

test_that("warns when deprecated 'uidlist' is passed", {
  index <- get_uid_list(test_docs)
  expect_warning(
    suppressMessages(simplify_idaifield(test_docs, uidlist = index)),
    "uidlist"
  )
})

test_that("warns when deprecated 'spread_fields' is passed", {
  expect_warning(
    suppressMessages(simplify_idaifield(test_docs, spread_fields = TRUE)),
    "spread_fields"
  )
})

test_that("warns when deprecated 'use_exact_dates' is passed", {
  expect_warning(
    suppressMessages(simplify_idaifield(test_docs, use_exact_dates = FALSE)),
    "use_exact_dates"
  )
})

test_that("warns when deprecated 'remove_config_names' is passed", {
  expect_warning(
    suppressMessages(simplify_idaifield(test_docs, remove_config_names = TRUE)),
    "remove_config_names"
  )
})
