# Tests for get_field_inputtypes() and extract_inputtypes().
#
# get_configuration() is not tested here — it requires a live Field Desktop
# connection and cannot be mocked without a running server.
# See test-get_configuration.R (or skip_if_no_field_desktop()) for those.
#
#
# ---- Shared mock objects ------------------------------------------------------
# Plain nested list mimicking the structure returned by get_configuration().
# Does NOT carry the idaifield_config class — extract_inputtypes() operates on
# plain nested lists and does not check the class, so this is intentional.
#
# Structure:
#   Operation (supercategory, has its own field "processor")
#     ├── Trench (subcategory, two fields)
#     └── Building (subcategory, no fields)
#   Find (supercategory, one field, no subcategories)
mock_nested_list <- list(
  categories = list(
    Operation = list(
      item = list(
        name   = "Operation",
        groups = list(
          stem = list(
            fields = list(
              processor = list(inputType = "checkboxes")
            )
          )
        )
      ),
      trees = list(
        Trench = list(
          item = list(
            name   = "Trench",
            groups = list(
              stem = list(
                fields = list(
                  shortDescription = list(inputType = "input"),
                  supervisor       = list(inputType = "checkboxes")
                )
              )
            )
          ),
          trees = list()
        ),
        Building = list(           # subcategory with no groups/fields at all
          item  = list(name = "Building"),
          trees = list()
        )
      )
    ),
    Find = list(
      item = list(
        name   = "Find",
        groups = list(
          stem = list(
            fields = list(
              weight = list(inputType = "float")
            )
          )
        )
      ),
      trees = list()
    )
  )
)

# Same structure wrapped in the idaifield_config class, as returned by
# get_configuration(). Required for get_field_inputtypes().
mock_config <- structure(mock_nested_list, class = "idaifield_config")

# Config with a field whose inputType is NULL. This simulates the case where
# a field has no explicit inputType in the config JSON. get_field_inputtypes()
# should convert the resulting "NULL" string to NA.
mock_config_null_inputtype <- structure(
  list(
    categories = list(
      Find = list(
        item = list(
          name   = "Find",
          groups = list(
            stem = list(
              fields = list(
                mystery = list(inputType = NULL),  # no inputType set
                weight  = list(inputType = "float")
              )
            )
          )
        ),
        trees = list()
      )
    )
  ),
  class = "idaifield_config"
)

# Config with categories key present but completely empty — no fields anywhere.
# extract_inputtypes() should return NULL; get_field_inputtypes() should stop().
empty_config <- structure(list(categories = list()), class = "idaifield_config")


# ---- extract_inputtypes() -----------------------------------------------------

test_that("returns NULL for a config with no fields", {
  result <- extract_inputtypes(empty_config)
  expect_null(result)
})

test_that("returns a list", {
  result <- extract_inputtypes(mock_nested_list)
  expect_type(result, "list")
})

test_that("each element has exactly the four expected names", {
  result <- extract_inputtypes(mock_nested_list)
  expected_names <- c("category", "parent", "fieldname", "inputType")
  for (entry in result) {
    expect_named(entry, expected_names)
  }
})

test_that("extracts the correct total number of fields", {
  # Operation: processor (1)
  # Trench: shortDescription + supervisor (2)
  # Building: none (0)
  # Find: weight (1)
  # Total: 4
  result <- extract_inputtypes(mock_nested_list)
  expect_length(result, 4)
})

test_that("supercategory with own fields: category == parent", {
  result <- extract_inputtypes(mock_nested_list)
  processor <- result[sapply(result, function(x) x$fieldname == "processor")][[1]]
  expect_equal(processor$category, "Operation")
  expect_equal(processor$parent,   "Operation")
})

test_that("subcategory fields have parent set to the supercategory", {
  result <- extract_inputtypes(mock_nested_list)
  trench_rows <- result[sapply(result, function(x) x$category == "Trench")]
  # All Trench fields should point back to Operation as parent
  expect_true(all(sapply(trench_rows, function(x) x$parent == "Operation")))
})

test_that("subcategory with no fields produces no entries", {
  result <- extract_inputtypes(mock_nested_list)
  building_rows <- result[sapply(result, function(x) x$category == "Building")]
  expect_length(building_rows, 0)
})

test_that("inputTypes are preserved correctly", {
  result <- extract_inputtypes(mock_nested_list)
  checkboxes <- result[sapply(result, function(x) !is.null(x$inputType) && x$inputType == "checkboxes")]
  # processor and supervisor are both checkboxes
  expect_length(checkboxes, 2)
})

test_that("output matches expected structure exactly (order-insensitive)", {
  # Keeping this test from the original test-extract_inputtypes.R.
  # expect_setequal is used because recursion order is not guaranteed.
  expected <- list(
    list(category = "Operation", parent = "Operation",
         fieldname = "processor",        inputType = "checkboxes"),
    list(category = "Trench",    parent = "Operation",
         fieldname = "shortDescription", inputType = "input"),
    list(category = "Trench",    parent = "Operation",
         fieldname = "supervisor",       inputType = "checkboxes"),
    list(category = "Find",      parent = "Find",
         fieldname = "weight",           inputType = "float")
  )
  result <- extract_inputtypes(mock_nested_list)
  expect_setequal(result, expected)
})

test_that("works on a plain list, does not require idaifield_config class", {
  # extract_inputtypes() is an internal helper that may be called with the raw
  # config list before it is classed. This should not cause an error.
  expect_no_error(extract_inputtypes(mock_nested_list))
})

test_that("works on the bundled test config without error", {
  expect_no_error(extract_inputtypes(config))
})

test_that("bundled config produces a non-empty result", {
  result <- extract_inputtypes(config)
  expect_gt(length(result), 0)
})


# ---- get_field_inputtypes() ---------------------------------------------------

test_that("stops if config is not an idaifield_config object", {
  expect_error(get_field_inputtypes(list()),
               regexp = "idaifield_config")
})

test_that("stops if config is NULL or NA", {
  expect_error(get_field_inputtypes(NULL))
  expect_error(get_field_inputtypes(NA))
})

test_that("stops if no fields are found in the config", {
  expect_error(get_field_inputtypes(empty_config),
               regexp = "failed")
})

test_that("returns a data.frame", {
  result <- get_field_inputtypes(mock_config)
  expect_s3_class(result, "data.frame")
})

test_that("has exactly four columns", {
  result <- get_field_inputtypes(mock_config)
  expect_equal(ncol(result), 4)
})

test_that("has correct column names", {
  result <- get_field_inputtypes(mock_config)
  expect_named(result, c("category", "parent", "fieldname", "inputType"))
})

test_that("all columns are character type", {
  result <- get_field_inputtypes(mock_config)
  expect_true(all(sapply(result, is.character)))
})

test_that("correct number of rows", {
  result <- get_field_inputtypes(mock_config)
  expect_equal(nrow(result), 4)
})

test_that("NULL inputType in config becomes NA in the data.frame", {
  result <- get_field_inputtypes(mock_config_null_inputtype)
  mystery_row <- result[result$fieldname == "mystery", ]
  expect_true(is.na(mystery_row$inputType))
})

test_that("non-NULL inputTypes are not affected by the NA replacement", {
  result <- get_field_inputtypes(mock_config_null_inputtype)
  weight_row <- result[result$fieldname == "weight", ]
  expect_equal(weight_row$inputType, "float")
})

test_that("works on the bundled test config", {
  result <- get_field_inputtypes(config)
  expect_s3_class(result, "data.frame")
  expect_named(result, c("category", "parent", "fieldname", "inputType"))
  expect_gt(nrow(result), 0)
})
