# TODO

## In general

- Better structure of tests with less specialized cases?
- Update the couch-db action a bit? See problems with \_changes etc.,
  and different configurations and contents.
- rename uidlist to index everywhere because that is what it is. (Not
  sure I am done with that.)
- Rewrite of simplify: Okay. But now think about the missing tools /
  utilities and vignettes to advertise them?
- Reduced functions, make it easier to maintain somehow.
  (HAHAHAHAHAHAHA)
- Clean up old code. (Ha.. )

## Maybes

- Some possibility to only update resources that have been changed since
  the last synch since loading everything is excessive for large
  projects.
- Getting CRAN-ready: Better structured tests that do not depend on
  DB-connections.
- Reduced messaging behaviour.

# March Madness Cleanup TODOs according to Claude

## 💀 Dead Code (Not Called Anywhere in the Pipeline)

**[`convert_to_onehot()`](https://lsteinmann.github.io/idaifieldR/reference/convert_to_onehot.md)**
— Exported, has a test, has docs. But
[`simplify_idaifield()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_idaifield.md)
never calls it. It was part of the old `spread_fields` behaviour, which
was deprecated. It’s just sitting there. It wants attention.

**[`fix_dating()`](https://lsteinmann.github.io/idaifieldR/reference/fix_dating.md)
and
[`bce_ce()`](https://lsteinmann.github.io/idaifieldR/reference/bce_ce.md)**
— They’re exported, tested, documented — but completely orphaned from
the actual simplification pipeline. The dating fields just fall through
to the generic [`unlist()`](https://rdrr.io/r/base/unlist.html) at the
bottom. It wants attention.

**[`idf_sepdim()`](https://lsteinmann.github.io/idaifieldR/reference/idf_sepdim.md)**
— You called this “VERY VERY BAD” yourself. It’s exported, never called
internally. Dead.

------------------------------------------------------------------------

## 🔨 Broken (Documented as Such)

:)

------------------------------------------------------------------------

## 🤔 Questionable Exports

**[`gather_languages()`](https://lsteinmann.github.io/idaifieldR/reference/gather_languages.md)**
— Exported, has tests, but the language selection in
[`simplify_single_resource()`](https://lsteinmann.github.io/idaifieldR/reference/simplify_single_resource.md)
is entirely commented out. So it’s a public function with no path
through the package to reach it. Power users could call it directly, but
is that the intent? Big todo to fix this!

**[`find_named_list()`](https://lsteinmann.github.io/idaifieldR/reference/find_named_list.md)**
— Exported, has a test. Never called internally. Appears to be a utility
for users to dig into the config list. Fine if intentional — but is it?
-\> Is used now to find the resource list, I should keep it but make the
doc more explicit on how one can use it.

**[`select_by()`](https://lsteinmann.github.io/idaifieldR/reference/select_by.md)**
— A deprecated wrapper for
[`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md).
Fine for backward compat, but it lives in `select_idaifield.R` instead
of `deprecated.R` where it belongs.

------------------------------------------------------------------------

## 🧹 Minor Mess

**[`proj_idf_client()`](https://lsteinmann.github.io/idaifieldR/reference/proj_idf_client.md)
is still chatty.** Still prints “Connected to project ‘X’ containing N
docs.” on every internal call. Every query, every
[`get_field_index()`](https://lsteinmann.github.io/idaifieldR/reference/get_field_index.md),
everything goes through this and yells at the user.

**[`idaifield_as_matrix()`](https://lsteinmann.github.io/idaifieldR/reference/idaifield_as_matrix.md)
example still uses
[`select_by()`](https://lsteinmann.github.io/idaifieldR/reference/select_by.md)
(deprecated).** Should be
[`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md).

|                                                                                                  |
|--------------------------------------------------------------------------------------------------|
| \## Aesthetics Find a better naming scheme for all functions and rename / deprecate accordingly. |

## Summary Table

| Item                                                                                                                                                          | Status      | Action                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|---------------------------------------------------------------------------------------------------|
| [`convert_to_onehot()`](https://lsteinmann.github.io/idaifieldR/reference/convert_to_onehot.md)                                                               | 🧹 Stale    | Document as standalone tool and use again                                                         |
| [`fix_dating()`](https://lsteinmann.github.io/idaifieldR/reference/fix_dating.md) + [`bce_ce()`](https://lsteinmann.github.io/idaifieldR/reference/bce_ce.md) | 🧹 Stale    | rethink into a better tool and then advertise                                                     |
| [`idf_sepdim()`](https://lsteinmann.github.io/idaifieldR/reference/idf_sepdim.md)                                                                             | 💀 Dead     | Rewrite or remove                                                                                 |
| [`proj_idf_client()`](https://lsteinmann.github.io/idaifieldR/reference/proj_idf_client.md) chattiness                                                        | 🧹 Annoying | Move message out                                                                                  |
| [`select_by()`](https://lsteinmann.github.io/idaifieldR/reference/select_by.md) example                                                                       | 🧹 Stale    | Update to [`idf_select_by()`](https://lsteinmann.github.io/idaifieldR/reference/idf_select_by.md) |
