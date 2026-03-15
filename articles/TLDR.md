# TLDR: Essential Workflow

Connect, import, simplify, analyse. That’s it.

``` r
library(idaifieldR)

conn    <- connect_idaifield(pwd = "hallo", project = "rtest")
docs    <- get_idaifield_docs(connection = conn)
index   <- get_field_index(conn)
config  <- get_configuration(conn)

pottery <- docs |>
  idf_select_by(by = "category", value = "Pottery") |>
  # Note: always supply the index of the *complete* database,
  # even when working with a subset — it is needed to resolve UUIDs.
  simplify_idaifield(index = index, config = config) |>
  idaifield_as_matrix() |>
  as.data.frame()
```

Or query the database directly instead of loading everything first:

``` r
pottery <- idf_query(conn, field = "category", value = "Pottery") |>
  simplify_idaifield(index = index, config = config) |>
  idaifield_as_matrix() |>
  as.data.frame()
```

For a full walkthrough see
[`vignette("Demo")`](https://lsteinmann.github.io/idaifieldR/articles/Demo.md).  
See also:
[`?idf_index_query`](https://lsteinmann.github.io/idaifieldR/reference/idf_index_query.md),
[`?idf_json_query`](https://lsteinmann.github.io/idaifieldR/reference/idf_json_query.md).
