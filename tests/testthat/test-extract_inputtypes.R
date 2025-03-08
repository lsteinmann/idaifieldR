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
            label = list(de = "Schnitt", en = "Trench"),
            groups = list(
              stem = list(
                fields = list(
                  shortDescription = list(
                    inputType = "input"
                  ),
                  supervisor = list(
                    inputType = "checkboxes"
                  )
                )
              )
            )
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
        name = "Project",
        label = list(de = "Projekt", en = "Project"),
        groups = list(
          stem = list(
            fields = list(
              description = list(
                inputType = "text"
              )
            )
          )
        )
      ),
      trees = list()
    )
  )
)

expected <- list(
  list(
    category = "Trench",
    parent = "Operation",
    field = "shortDescription",
    inputType = "input"
  ),
  list(
    category = "Project",
    parent = "Project",
    field = "description",
    inputType = "text"
  ),
  list(
    category = "Trench",
    parent = "Operation",
    field = "supervisor",
    inputType = "checkboxes"
  )
)


test_that("format of output is as expected", {
  result <- extract_inputtypes(my_list)

  expect_setequal(result, expected)
})
