# Extending travelpaths

**travelpaths** uses a plugin system modelled after the
[parsnip](https://parsnip.tidymodels.org/) pattern from tidymodels. A
specification object captures what algorithm to run and with which
parameters. A separate registry maps each (model, mode, engine) triple
to a concrete fitting function. The two sides are joined at the point of
calling `fit()`.

The public API for extending the package consists of three functions:

| Function | Purpose |
|----|----|
| `new_travelpath_spec(cls, args, eng_args, mode, engine)` | Create a new specification object |
| `register_fit_function(model, mode, engine, fit_function)` | Register the engine specific fit function |
| `register_argument_mapping(model, mode, engine, argument_mapping)` | Rename arguments before they are passed to the fit function |

## Writing a specification constructor

A specification constructor is a function that collects parameters into
a named list and passes them to
[`new_travelpath_spec()`](../reference/new_travelpath_spec.md).

``` r

threshold_stops <- function(
  mode = "segmentation",
  engine = "infostop",
  r1 = 10,
  min_size = 2L,
  min_staying_time = 300L,
  max_time_between = 86400L,
  output_col = "stop_id"
) {
  args <- list(
    r1 = r1,
    min_size = min_size,
    min_staying_time = min_staying_time,
    max_time_between = max_time_between,
    stop_id_col = output_col
  )
  new_travelpath_spec(
    "threshold_stops",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}
```

[`new_travelpath_spec()`](../reference/new_travelpath_spec.md) validates
every argument with [checkmate](https://mllg.github.io/checkmate/) and
returns an object inheriting from `"travelpath_spec"`:

``` r

spec <- threshold_stops()
class(spec)
```

    ## [1] "threshold_stops" "travelpath_spec"

``` r

str(spec)
```

    ## List of 5
    ##  $ args    :List of 5
    ##   ..$ r1              : num 10
    ##   ..$ min_size        : int 2
    ##   ..$ min_staying_time: int 300
    ##   ..$ max_time_between: int 86400
    ##   ..$ stop_id_col     : chr "stop_id"
    ##  $ eng_args: list()
    ##  $ mode    : chr "segmentation"
    ##  $ method  : NULL
    ##  $ engine  : chr "infostop"
    ##  - attr(*, "class")= chr [1:2] "threshold_stops" "travelpath_spec"

- `args` holds the parameters that are present in all `threshold_stops`
  implementations.
- `eng_args` holds parameters that are engine-specific and should not be
  exposed in the constructor signature (pass
  [`list()`](https://rdrr.io/r/base/list.html) when unused).

## Registering a fit function

`register_fit_function(model, mode, engine, fit_function)` adds the fit
function to the registry so that `fit()` dispatches correctly based on
the specification object.

``` r

register_fit_function(
  "threshold_stops", "segmentation", "infostop", infostop::identify_stops
)
```

The `fit_function` must accept `data` as its **first** positional
argument, followed by keyword arguments matching the names defined in
`args` and `eng_args`. If the caller passes extra `...` arguments to
`fit()`, they are appended last and override arguments from the
specification.

## Updating a specification

[`update.travelpath_spec()`](../reference/update.travelpath_spec.md)
lets callers change individual parameters without rebuilding the spec
from scratch.

``` r

spec |> update(r1 = 25, min_size = 3L) |> str()
```

    ## List of 5
    ##  $ args    :List of 5
    ##   ..$ r1              : num 25
    ##   ..$ min_size        : int 3
    ##   ..$ min_staying_time: int 300
    ##   ..$ max_time_between: int 86400
    ##   ..$ stop_id_col     : chr "stop_id"
    ##  $ eng_args: list()
    ##  $ mode    : chr "segmentation"
    ##  $ method  : NULL
    ##  $ engine  : chr "infostop"
    ##  - attr(*, "class")= chr [1:2] "threshold_stops" "travelpath_spec"

Use `fresh = TRUE` to reset all unspecified parameters to their
constructor defaults before applying the new values:

``` r

# Start from threshold_stops(r1 = 99, min_size = 9L), reset everything,
# then apply r1 = 5.
threshold_stops(r1 = 99, min_size = 9L) |>
  update(fresh = TRUE, r1 = 5) |> str()
```

    ## List of 5
    ##  $ args    :List of 5
    ##   ..$ r1              : num 5
    ##   ..$ min_size        : int 2
    ##   ..$ min_staying_time: int 300
    ##   ..$ max_time_between: int 86400
    ##   ..$ output_col      : chr "stop_id"
    ##  $ eng_args: list()
    ##  $ mode    : chr "segmentation"
    ##  $ method  : NULL
    ##  $ engine  : chr "infostop"
    ##  - attr(*, "class")= chr [1:2] "threshold_stops" "travelpath_spec"

A `params` named list is an alternative to `...` and can be combined
with it:

``` r

update(spec, params = list(r1 = 50), min_size = 4L) |> str()
```

    ## List of 5
    ##  $ args    :List of 5
    ##   ..$ r1              : num 50
    ##   ..$ min_size        : int 4
    ##   ..$ min_staying_time: int 300
    ##   ..$ max_time_between: int 86400
    ##   ..$ stop_id_col     : chr "stop_id"
    ##  $ eng_args: list()
    ##  $ mode    : chr "segmentation"
    ##  $ method  : NULL
    ##  $ engine  : chr "infostop"
    ##  - attr(*, "class")= chr [1:2] "threshold_stops" "travelpath_spec"

## Registering an argument mapping

Engine functions sometimes use different parameter names than the
canonical travelpaths names. In this case you have two options

1.  write a wrapper function that does additional validation and the
    mapping of the arguments,
2.  if there are only small differences you can register an argument
    mapping.

[`register_argument_mapping()`](../reference/register_argument_mapping.md)
declares a renaming that is applied automatically inside `fit()` before
the call is assembled.

The `argument_mapping` argument is a named character vector where each
name is the spec-level name and the corresponding value is the
engine-level name:

``` r

register_argument_mapping(
  "change_point_permtest", "segmentation", "cpt",
  c("n_permutations" = "n")
)
```

With this mapping in place, a spec arg called `n_permutations` is
renamed to `n` before being forwarded to
[`cpt::change_point_test`](https://rdrr.io/pkg/cpt/man/change_point_test.html).

## The fit() dispatch pipeline

[`fit.travelpath_spec()`](../reference/fit.travelpath_spec.md)
orchestrates the following steps every time a spec is fitted:

1.  Look up the registered fit function for `(model, mode, engine)`.
2.  Build the argument list: `c(list(data), args, eng_args)`.
3.  Apply any registered argument mappings (see
    [`register_argument_mapping()`](../reference/register_argument_mapping.md)).
4.  Merge in extra arguments supplied via `...`.
5.  Validate the assembled argument list against the fit function
    signature.
6.  Evaluate the call and attach a `<mode>_fit` class to the result.

``` r

result <- fit(threshold_stops(r1 = 20), tf_mini)
```

    ## Error:
    ## ! in 'identify_stops_internal(data = split_mat_by_id(cbind(easting(data), northing(data), as.integer(time(data))), id(data)), r1 = r1, min_size = min_size, min_staying_time = min_staying_time, max_time_between = max_time_between, distance_metric = "euclidean")' infostop is not initialized, use 'infostop_initialize' to initialize infostop!

``` r

result
```

    ## Error:
    ## ! object 'result' not found

## Dry-run mode

Passing `dry_run = TRUE` to `fit()` skips evaluation and returns the
assembled call object instead. This is the recommended way to verify
that argument forwarding and renaming are working correctly without
executing the underlying engine.

``` r

rcall <- fit(threshold_stops(r1 = 20, min_size = 3L), tf_mini, dry_run = TRUE)
```

Convert the call to a list to inspect each element:

``` r

str(as.list(rcall))
```

    ## List of 7
    ##  $                 :function (data, r1 = 10, min_size = 2L, min_staying_time = 300L, max_time_between = 86400L, 
    ##     output_col = "stop_id", ...)  
    ##  $                 :Classes 'trackframe' and 'data.frame':   11 obs. of  4 variables:
    ##   ..$ time    : POSIXct[1:11], format: "2025-10-14 13:48:46" "2025-10-14 13:49:46" ...
    ##   ..$ northing: num [1:11] 48.2 48.2 48.2 48.2 48.2 ...
    ##   ..$ easting : num [1:11] 16.4 16.4 16.4 16.4 16.4 ...
    ##   ..$ id      : chr [1:11] "track_1" "track_1" "track_1" "track_1" ...
    ##   ..- attr(*, "sf_column")= chr "geometry"
    ##   ..- attr(*, "agr")= Factor w/ 3 levels "constant","aggregate",..: NA NA NA NA NA
    ##   .. ..- attr(*, "names")= chr [1:5] "time" "northing" "easting" "id" ...
    ##   ..- attr(*, "group_col")= chr "sft_group"
    ##   ..- attr(*, "time_col")= chr "time"
    ##   ..- attr(*, "transformation_info")=List of 9
    ##   .. ..$ names      : chr [1:6] "time" "northing" "easting" "id" ...
    ##   .. ..$ row.names  : int [1:11] 1 2 3 4 5 6 7 8 9 10 ...
    ##   .. ..$ sf_column  : chr "geometry"
    ##   .. ..$ agr        : Factor w/ 3 levels "constant","aggregate",..: NA NA NA NA NA
    ##   .. .. ..- attr(*, "names")= chr [1:5] "time" "northing" "easting" "id" ...
    ##   .. ..$ group_col  : chr "sft_group"
    ##   .. ..$ time_col   : chr "time"
    ##   .. ..$ error_col  : logi NA
    ##   .. ..$ class      : chr [1:3] "sftrack" "sf" "data.frame"
    ##   .. ..$ group_names: chr "id"
    ##   ..- attr(*, "time")= chr "time"
    ##   ..- attr(*, "easting")= chr "easting"
    ##   ..- attr(*, "northing")= chr "northing"
    ##   ..- attr(*, "id")= chr "id"
    ##   ..- attr(*, "crs")= chr "EPSG:32632"
    ##   ..- attr(*, "crs_type")= chr "projected"
    ##  $ r1              : num 20
    ##  $ min_size        : int 3
    ##  $ min_staying_time: int 300
    ##  $ max_time_between: int 86400
    ##  $ stop_id_col     : chr "stop_id"

The `dry_run` flag itself is stripped from the call list so it never
reaches the engine.

Arguments passed via `...` to `fit()` are merged after the spec args, so
they can be used to override individual values for a single call without
modifying the spec:

``` r

call_list_override <- as.list(
  fit(threshold_stops(), tf_mini, dry_run = TRUE, stop_id_col = "my_stop")
)
call_list_override[["stop_id_col"]]
```

    ## [1] "my_stop"

## Complete worked example

The steps below show how to add a new model.

1.  Write a specification constructor. If a constructor already exists
    and only a new engine is added, this step can be omitted.
2.  Optionally wrap the engine function to handle validation or argument
    translation before registration.
3.  Register the fit function.

### Specification constructor

The constructor collects parameters into a named list and passes them to
[`new_travelpath_spec()`](../reference/new_travelpath_spec.md). The
first argument is the model name (used as a key in the registry), `args`
holds canonical parameters shared across engines, and `eng_args` holds
engine-specific parameters not exposed in the constructor signature.

``` r

my_model <- function(
  mode   = "segmentation",
  engine = "my_engine",
  threshold = 0.5,
  max_gap   = 100L
) {
  args <- list(threshold = threshold, max_gap = max_gap)
  new_travelpath_spec(
    "my_model",
    args     = args,
    eng_args = list(),
    mode     = mode,
    engine   = engine
  )
}
```

### Wrapper function

The wrapper function must accept `data` as its first positional
argument, followed by the same parameter names used in `args`. The `...`
argument allows `fit()` to forward additional arguments. Here
engine-specific validation can be added.

``` r

my_fit_fn <- function(data, threshold = 0.5, max_gap = 100L, ...) {
  checkmate::assert_class(data, "trackframe")
  checkmate::assert_numeric(threshold, lower = 0, finite = TRUE, any.missing = FALSE)
  checkmate::assert_integerish(max_gap, lower = 0, any.missing = FALSE)
  stop_id <- c(1, sample(c(0, 1), NROW(data) - 1, replace = TRUE))
  data[["rand_stop_id"]] <- cumsum(stop_id)
  return(data)
}
```

### Register fit function

Register the wrapper under the `(model, mode, engine)` triple. In a
package designed to enhance the functionality of the travelpaths
framework this call belongs in `.onLoad()` inside `R/zzz.R` so the
registry is populated when the package is attached.

``` r

register_fit_function("my_model", "segmentation", "my_engine", my_fit_fn)
```

### Inspect registered arguments

The [`arguments()`](../reference/arguments.md) generic extracts the
formal arguments of the fit function associated with a specification.
This is useful for verifying that the registered function matches what
the spec expects:

``` r

arguments(my_model())
```

    ## Function with 4 arguments:
    ##  $ data     : symbol 
    ##  $ threshold: num 0.5
    ##  $ max_gap  : int 100
    ##  $ ...      : symbol

### Use the model

Once registered, the model can be used with the standard `fit()`
interface.

``` r

data("tf_mini")
spec <- my_model()
fitted <- fit(spec, tf_mini)
fitted
```

    ## <my_engine_fit>: 
    ## - spec_str: list[5]
    ##   - args
    ##     - threshold: num 0.5
    ##     - max_gap  : int 100
    ##   - eng_args: list()
    ##   - mode    : chr "segmentation"
    ##   - method  : NULL
    ##   - engine  : chr "my_engine"
    ## - fit: NULL[0]
    ##  NULL

## Packaging guidelines

When adding models in an extension package rather than a standalone
script, keep these points in mind:

- **Register in `.onLoad()`**, not at the top level. Place
  [`register_fit_function()`](../reference/register_fit_function.md) and
  [`register_argument_mapping()`](../reference/register_argument_mapping.md)
  calls in `R/zzz.R` inside `.onLoad()`. This ensures the registry is
  populated whenever the namespace is loaded.

- **Guard optional engines** with `is_pkg_installed()`. If the engine
  package is listed under `Suggests` rather than `Imports`, wrap the
  registration in a conditional so the package still loads when the
  engine is absent:

``` r

.onLoad <- function(libname, pkgname) {
  if (is_pkg_installed("infostop")) {
    register_fit_function(
      "my_model", "segmentation", "infostop",
      infostop::identify_stops
    )
  }
}
```

- **Startup messages** from `.onAttach()` automatically list all
  registered models, so users see which engines are available.
