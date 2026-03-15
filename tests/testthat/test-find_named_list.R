my_list <- list(
  projectLanguages = list("de", "en"),
  categories = list(
    Operation = list(
      item = list(
        name = "Operation",
        label = list(de = "Maßnahme", en = "Operation")
      ),
      trees = list(
        Trench = list(
          item = list(
            name = "Trench",
            label = list(de = "Schnitt", en = "Trench")
          ),
          trees = list()
        ),
        Building = list(
          item = list(
            name = "Building",
            label = list(de = "Bauwerk", en = "Building")
          ),
          trees = list()
        )
      )
    ),
    Sample = list(
      item = list(
        name = "Sample",
        label = list(de = "Probe", en = "Sample")
      ),
      trees = list()
    )
  )
)

test_that("finds the single sub-list if not nested", {
  expected <- list(
    item = list(
      name = "Sample",
      label = list(de = "Probe", en = "Sample")
    ),
    trees = list()
  )

  result <- find_named_list(nested_list = my_list, "Sample")

  expect_equal(result, expected)
})

test_that("finds the single sub-list, even if nested", {
  expected <- list(
    item = list(
      name = "Building",
      label = list(de = "Bauwerk", en = "Building")
    ),
    trees = list()
  )

  result <- find_named_list(nested_list = my_list, "Building")

  expect_equal(result, expected)
})


