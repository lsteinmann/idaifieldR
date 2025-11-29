# Check Version of idaifieldR

Checks if a new version of idaifieldR is available (runs on attach).

## Usage

``` r
check_idaifieldr_version(installed_version = getNamespaceVersion("idaifieldR"))
```

## Arguments

- installed_version:

  version of idaifieldR currently in use

## Value

TRUE if current release is used, FALSE if not.

## Examples

``` r
if (FALSE) { # \dontrun{
check_idaifieldr_version(packageVersion('idaifieldR'))
} # }
```
