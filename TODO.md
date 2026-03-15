# TODO

## In general
* Better structure of tests with less specialized cases?
* Update the couch-db action a bit? See problems with _changes etc., and different configurations and contents.
* rename uidlist to index everywhere because that is what it is. 
* Completely rewrite simplify & its utilities...
    * just produce methods for all inputtype, get the config via the new configuration endpoint and then reformat each column according to the specifications for the corresponding inputtype. you can get everything easily via the new endpoint! 
* Reduced functions, make it easier to maintain somehow. 
* Clean up old code.

## Maybes
* Some possibility to only update resources that have been changed since the last
synch since loading everything is excessive for large projects.
* Getting CRAN-ready: Better structured tests that do not depend on DB-connections.
* Reduced messaging behaviour. 

# March Madness Cleanup TODOs according to Claude

## 💀 Dead Code (Not Called Anywhere in the Pipeline)

**`convert_to_onehot()`** — Exported, has a test, has docs. But `simplify_idaifield()` never calls it. It was part of the old `spread_fields` behaviour, which was deprecated. It's just sitting there.

**`fix_dating()` and `bce_ce()`** — Same story. `simplify_single_resource()` doesn't call either. They're exported, tested, documented — but completely orphaned from the actual simplification pipeline. The dating fields just fall through to the generic `unlist()` at the bottom.

**`idf_sepdim()`** — You called this "VERY VERY BAD" yourself. It's exported, never called internally. Dead.

---

## 🔨 Broken (Documented as Such)

:)

---

## 🤔 Questionable Exports

**`gather_languages()`** — Exported, has tests, but the language selection in `simplify_single_resource()` is entirely commented out. So it's a public function with no path through the package to reach it. Power users could call it directly, but is that the intent?

**`find_named_list()`** — Exported, has a test. Never called internally. Appears to be a utility for users to dig into the config list. Fine if intentional — but is it? -> Is used now to find the resource list, I should keep it but make the doc more explicit on how one can use it. 

**`select_by()`** — A deprecated wrapper for `idf_select_by()`. Fine for backward compat, but it lives in `select_idaifield.R` instead of `deprecated.R` where it belongs.

---

## 🧹 Minor Mess

**`proj_idf_client()` is still chatty.** Still prints "Connected to project 'X' containing N docs." on every internal call. Every query, every `get_field_index()`, everything goes through this and yells at the user.

**`idaifield_as_matrix()` example still uses `select_by()` (deprecated).** Should be `idf_select_by()`.


---

## Summary Table

| Item | Status | Action |
|---|---|---|
| `convert_to_onehot()` | 💀 Dead | Remove or document as standalone tool |
| `fix_dating()` + `bce_ce()` | 💀 Dead | Same question |
| `idf_sepdim()` | 💀 Dead | Rewrite or remove |
| `proj_idf_client()` chattiness | 🧹 Annoying | Move message out |
| `idaifield_as_matrix()` example | 🧹 Stale | Update to `idf_select_by()` |