# Register an argument mapping for a model specification

Register an argument mapping for a model specification

## Usage

``` r
register_argument_mapping(model, mode, engine, argument_mapping)
```

## Arguments

- model:

  a character string giving the model name, e.g., \`"threshold_stops"\`.

- mode:

  a character string giving the mode (currently \`"segmentation"\` and
  \`"grouping"\` are supported).

- engine:

  a character string giving the engine, e.g., \`"smoove"\`.

- argument_mapping:

  a named character vector mapping the names used in
  \`object\[\["args"\]\]\` to the actual argument names expected by the
  fit function. The format is \`c("old_name_1" = "new_name_1",
  "old_name_2" = "new_name_2", ...)\`.

## Value

Invisible \`NULL\`.
