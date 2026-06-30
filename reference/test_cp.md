# Test RACVM change point

Identifies appropriate models on either side of a change point

## Usage

``` r
test_cp(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
)

# S3 method for class 'trackframe'
test_cp(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
)

# S3 method for class 'data.frame'
test_cp(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
)

# S3 method for class 'move2'
test_cp(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
)

# S3 method for class 'sftrack'
test_cp(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
)
```

## Arguments

- data:

  an object of class `trackframe`

- cp:

  change point

- start:

  beginning time of segment to analyze

- end:

  end time of segment to analyze

- modelset:

  set of models to compare (combination of UCVM, ACVM, RCVM, RACVM, or
  `all`, which includes all of them)

- spline:

  whether or not to use the spline approximation for the final estimate.

- criterion:

  selection criterion - either BIC or AIC (can be upper- or lowercased)

- time_units:

  time units of calculations (e.g. "secs", "mins", "hours", "days")

- ...:

  further params to `getFit` internal function

## Examples

``` r
tf <- sim_travel_path(1000, format = "trackframe")
#> Error in as.trackframe.sf(data, time_col = time_col, easting_col = easting_col,     northing_col = northing_col, id_col = id_col, sort = sort,     coerce_to = coerce_to, ...): Column easting set as sf_easting_col, but exists also in data.
#>       Remove column easting in data, or change sf_easting_col using tf_options()
test_cp(tf, 10, 1, 100)
#> Error: object 'tf' not found
```
