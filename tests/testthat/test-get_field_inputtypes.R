# Tests for get_field_inputtypes() and extract_inputtypes().
#
# get_configuration() is not tested here — it requires a live Field Desktop
# connection and cannot be mocked without a running server.
# See test-get_configuration.R (or skip_if_no_field_desktop()) for those.
#
#
# ---- Shared mock objects ------------------------------------------------------

# Plain nested list mimicking the structure returned by get_configuration()
# after name_all_nested_lists() has been applied.
#
# Reflects the real config structure observed in the rtest project:
# - Groups have name/label/defaultLabel alongside fields (only fields matters
#   for extraction, but extras should not cause errors)
# - Multiple groups per category (stem, properties, dimension)
# - Composite field with a $subfields key (subfields must be silently ignored)
# - Supercategory with its own fields (parent == category)
# - Subcategory pointing back to supercategory as parent
# - Subcategory with no fields at all
#
# Structure:
#   Find (supercategory, fields in stem + properties groups)
#     └── Pottery (subcategory, fields across stem + dimension groups)
#     └── Brick (subcategory, no fields)
mock_nested_list <- list(
  categories = list(
    Find = list(
      item = list(
        name = "Find",
        groups = list(
          stem = list(
            name   = "stem",
            label  = list(en = "Core"),
            fields = list(
              identifier = list(inputType = "identifier"),
              processor  = list(inputType = "checkboxes")
            )
          ),
          properties = list(
            name   = "properties",
            label  = list(en = "Properties"),
            fields = list(
              weight = list(inputType = "weight")
            )
          )
        )
      ),
      trees = list(
        Pottery = list(
          item = list(
            name = "Pottery",
            groups = list(
              stem = list(
                name   = "stem",
                label  = list(en = "Core"),
                fields = list(
                  vesselForm = list(inputType = "dropdown")
                )
              ),
              dimension = list(
                name   = "dimension",
                label  = list(en = "Dimensions"),
                fields = list(
                  dimensionLength = list(inputType = "dimension"),
                  # Composite field: has $subfields but extract_inputtypes()
                  # must only record the composite itself, not its subfields.
                  `rtest:compositeInput` = list(
                    inputType = "composite",
                    subfields = list(
                      list(name = "subfieldA", inputType = "input"),
                      list(name = "subfieldB", inputType = "dropdown")
                    )
                  )
                )
              )
            )
          ),
          trees = list()
        ),
        Brick = list(           # subcategory with no groups or fields
          item  = list(name = "Brick"),
          trees = list()
        )
      )
    )
  )
)

# Wrapped with the idaifield_config class, as returned by get_configuration().
mock_config <- structure(mock_nested_list, class = "idaifield_config")

# Config with categories present but no fields anywhere.
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
  for (entry in result) {
    expect_named(entry, c("category", "parent", "fieldname", "inputType"))
  }
})

test_that("extracts the correct total number of fields", {
  # Find/stem:       identifier, processor (2)
  # Find/properties: weight (1)
  # Pottery/stem:    vesselForm (1)
  # Pottery/dim:     dimensionLength, rtest:compositeInput (2)
  # Brick:           none (0)
  # Total: 6 — composite appears as ONE row, subfields do not appear
  result <- extract_inputtypes(mock_nested_list)
  expect_length(result, 6)
})

test_that("supercategory fields have category == parent", {
  result <- extract_inputtypes(mock_nested_list)
  find_rows <- result[sapply(result, function(x) x$category == "Find")]
  expect_true(all(sapply(find_rows, function(x) x$parent == "Find")))
})

test_that("subcategory fields have parent set to the supercategory", {
  result <- extract_inputtypes(mock_nested_list)
  pottery_rows <- result[sapply(result, function(x) x$category == "Pottery")]
  expect_true(all(sapply(pottery_rows, function(x) x$parent == "Find")))
})

test_that("fields from multiple groups in the same category are all extracted", {
  result <- extract_inputtypes(mock_nested_list)
  find_fieldnames <- sapply(
    result[sapply(result, function(x) x$category == "Find")],
    function(x) x$fieldname
  )
  # stem group contributes identifier + processor, properties group contributes weight
  expect_setequal(find_fieldnames, c("identifier", "processor", "weight"))
})

test_that("subcategory with no fields produces no entries", {
  result <- extract_inputtypes(mock_nested_list)
  brick_rows <- result[sapply(result, function(x) x$category == "Brick")]
  expect_length(brick_rows, 0)
})

test_that("composite field appears as a single entry with inputType 'composite'", {
  result <- extract_inputtypes(mock_nested_list)
  composite_rows <- result[sapply(result, function(x) x$fieldname == "rtest:compositeInput")]
  expect_length(composite_rows, 1)
  expect_equal(composite_rows[[1]]$inputType, "composite")
})

test_that("subfields of composite field do not appear as separate entries", {
  result <- extract_inputtypes(mock_nested_list)
  all_fieldnames <- sapply(result, function(x) x$fieldname)
  # subfieldA and subfieldB are inside $subfields — must not appear at top level
  expect_false("subfieldA" %in% all_fieldnames)
  expect_false("subfieldB" %in% all_fieldnames)
})

test_that("extra keys in group (name, label, defaultLabel) do not cause errors", {
  # Real groups from Field Desktop have name/label/defaultLabel alongside
  # fields. Only fields should be processed; extras must be silently ignored.
  expect_no_error(extract_inputtypes(mock_nested_list))
})

test_that("works on a plain list without idaifield_config class", {
  # extract_inputtypes() is an internal helper that operates on plain lists.
  expect_no_error(extract_inputtypes(mock_nested_list))
})

test_that("output matches expected structure exactly (order-insensitive)", {
  expected <- list(
    list(category = "Find",    parent = "Find",
         fieldname = "identifier",           inputType = "identifier"),
    list(category = "Find",    parent = "Find",
         fieldname = "processor",            inputType = "checkboxes"),
    list(category = "Find",    parent = "Find",
         fieldname = "weight",               inputType = "weight"),
    list(category = "Pottery", parent = "Find",
         fieldname = "vesselForm",           inputType = "dropdown"),
    list(category = "Pottery", parent = "Find",
         fieldname = "dimensionLength",      inputType = "dimension"),
    list(category = "Pottery", parent = "Find",
         fieldname = "rtest:compositeInput", inputType = "composite")
  )
  result <- extract_inputtypes(mock_nested_list)
  expect_setequal(result, expected)
})

test_that("works on the bundled test config without error", {
  expect_no_error(extract_inputtypes(config))
})

test_that("bundled config produces a non-empty result", {
  result <- extract_inputtypes(config)
  expect_gt(length(result), 0)
})

test_that("bundled config contains a composite field entry", {
  result <- extract_inputtypes(config)
  input_types <- sapply(result, function(x) x$inputType)
  expect_true("composite" %in% input_types)
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
  expect_equal(nrow(result), 6)
})

test_that("composite field appears in result with inputType 'composite'", {
  result <- get_field_inputtypes(mock_config)
  composite_row <- result[result$fieldname == "rtest:compositeInput", ]
  expect_equal(nrow(composite_row), 1)
  expect_equal(composite_row$inputType, "composite")
})

test_that("works on the bundled test config", {
  result <- get_field_inputtypes(config)
  expect_s3_class(result, "data.frame")
  expect_named(result, c("category", "parent", "fieldname", "inputType"))
  expect_gt(nrow(result), 0)
})
