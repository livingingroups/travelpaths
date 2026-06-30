# Find single change point

Finds a single change point in UCVM parameters (time scale \\tau\\ and
rms speed \\eta\\) of a movement.

## Usage

``` r
find_single_break_point(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
)

# S3 method for class 'trackframe'
find_single_break_point(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
)

# S3 method for class 'data.frame'
find_single_break_point(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
)

# S3 method for class 'move2'
find_single_break_point(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
)

# S3 method for class 'sftrack'
find_single_break_point(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
)
```

## Arguments

- data:

  an object of class `trackframe`

- k:

  tuning parameter for the smoothing of the likelihood profile spline.
  The number of knots is "length(T)/4 \* k" - the lower the value of k,
  the smoother the spline.

- method:

  one of "sweep" or "optimize". See details.

- plotme:

  whether to plot the resulting likelihood (only if method is "sweep").

- time_units:

  time units of calculations (e.g. "secs", "mins", "hours", "days")

- ...:

  additional parameters to pass to `estimateUCVM` function, in
  particular the method of estimation. Under most conditions, fairly
  reliable and fast results are provided by the default `vLike`
  (velocity likelihood) method.

## Details

Two methods are provided: "sweep", which scans a set of possible change
points, smooths the likelihoods and selects the maximum, or "optimize"
which uses R's single dimension optimization algorithms to find the most
likely change point. The latter is faster, but can be unreliable because
the likelihood profiles are typically quite rough.

## Examples

``` r
set.seed(2025)
tf <- sim_travel_path(50, format = "trackframe")
#> Error in as.trackframe.sf(data, time_col = time_col, easting_col = easting_col,     northing_col = northing_col, id_col = id_col, sort = sort,     coerce_to = coerce_to, ...): Column easting set as sf_easting_col, but exists also in data.
#>       Remove column easting in data, or change sf_easting_col using tf_options()
find_single_break_point(tf, method = "sweep")
#> Error: object 'tf' not found
find_single_break_point(tf, method = "optimize")
#> Error: object 'tf' not found
```
