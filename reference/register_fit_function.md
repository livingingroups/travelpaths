# Register a new fit function

Register a new fit function

## Usage

``` r
register_fit_function(model, mode, engine, fit_function)
```

## Arguments

- model:

  a character string giving the model name, e.g., \`"threshold_stops"\`.

- mode:

  a character string giving the mode, currently \`"segmentation"\` and
  \`"grouping"\` are supported.

- engine:

  a character string giving the engine, e.g., \`"smoove"\`.

- fit_function:

  a function to be used for fitting.

## Value

Invisible \`NULL\`.

## Examples

``` r
if (FALSE) { # \dontrun{
register_fit_function("threshold_stops", "segmentation", "infostop",
  infostop::identify_stops)
} # }
```
