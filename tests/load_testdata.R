library(idaifieldR)
test_docs <- readRDS(system.file("testdata", "idaifield_test_docs.RDS",
                                 package = "idaifieldR"))
test_resources <- maybe_unnest_docs(test_docs)

test_simple <- simplify_idaifield(test_resources)

config <- readRDS(system.file("testdata", "idaifield_test_config.RDS",
                              package = "idaifieldR"))


# Minimal example resource covering all major field types in iDAI.field.
# One example of each type, no redundancy.

minimal_test_resource <- list(

  # --- Simple scalar fields
  identifier       = "TestObject-001",
  category         = "Pottery",
  amount           = 1L,
  hasRestoration   = TRUE,
  condition        = "gut",

  # --- Checkbox field (multiple values from a valuelist)
  clayColorOutside = list("ocker", "violett"),

  # --- Multilingual text field
  clayColorOutsideMunsell = list(en = "5YR 6/4", de = "5YR 6/4"),

  # --- Dropdown range field (period)
  # period = list(value = "Klassisch"),

  # --- Dating field
  dating = list(
    list(
      type  = "range",
      begin = list(inputType = "bce", inputYear = 400, year = -400),
      end   = list(inputType = "ce",  inputYear = 100, year =  100),
      isImprecise = FALSE,
      isUncertain = FALSE
    )
  ),

  # --- Measurement field (single value)
  dimensionLength = list(
    list(
      inputValue    = 10,
      inputUnit     = "cm",
      isImprecise   = FALSE,
      measurementPosition = "Maximale Ausdehnung",
      measurementComment  = list(en = "single value", de = "Einzelwert"),
      value         = 100000
    )
  ),

  # --- Measurement field (range value)
  dimensionWidth = list(
    list(
      inputValue        = 10,
      inputRangeEndValue = 15,
      inputUnit         = "cm",
      isImprecise       = TRUE,
      rangeMin          = 100000,
      rangeMax          = 150000
    )
  ),

  # --- Composite field
  `rtest:compositeInput` = list(
    list(
      subfieldSingleLine = list(en = "English input", de = "Deutsche Eingabe"),
      subfieldDropdown   = "Basalt",
      subfieldCheckboxes = list("Arretina schwarz", "Campana B Imitation")
    )
  ),

  # --- Relations (raw UUIDs as they come from the DB)
  relations = list(
    isRecordedIn = list("15754929-dd98-acfa-bfc2-016b4d5582fe"),
    liesWithin   = list("02932bc4-22ce-3080-a205-e050b489c0c2"),
    isDepictedIn = list(
      "27c5e37f-a0dc-4c89-b9ae-5d429468ffc1",
      "7d4f9b2b-411e-4053-8c67-625f859536fb"
    )
  ),

  # --- Internal ID
  id = "0569d787-aa67-e105-3a27-cba29012e78e",

  # --- Geometry (GeoJSON structure as parsed from the API)
  geometry = list(
    type = "Point",
    coordinates = list(524375.9, 4153759.6)
  )
)





skip_if_no_connection <- function() {
  connection <- suppressMessages(
    connect_idaifield(serverip = "127.0.0.1", project = "rtest",
                      pwd = "hallo", ping = FALSE)
    )

  ping <- suppressWarnings(suppressMessages(idf_ping(connection)))

  if (ping) {
    connection$status <- idf_ping(connection)
    return(connection)
  } else {
    skip("Test skipped, needs DB-connection")
  }
}

skip_if_no_field_desktop <- function(pwd = "hallo") {
  headers <- list(`Content-Type` = "application/json",
                  Accept = "application/json")
  client <- crul::HttpClient$new(url = "http://localhost:3000/info",
                                 opts = crul::auth(user = "R", pwd = pwd),
                                 headers = headers)
  response <- client$get()
  if (!response$success()) {
    skip("Test skipped, Field Desktop not available on localhost.")
  }
}

