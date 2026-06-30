# Generate Random Travel Path

This function generates a random travel path with coordinates
(easting/northing for format trackframe and northing/easting else) and
time values. The path can include stationary periods and movements with
configurable parameters. The following output formats are supported:
`"trackframe"` (easting/northing), `"data.frame"`, `"matrix"`,
`"sftrack"` or `"move2"`.

## Usage

``` r
sim_travel_path(
  size,
  max_step = 0.001,
  time_increment = 60,
  start_location = c(0, 0),
  start_time = as.POSIXct(format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  stay_prob = 0.2,
  format = c("trackframe", "data.frame", "matrix", "sftrack", "move2")
)
```

## Arguments

- size:

  An integer giving the number of points to generate in the path.

- max_step:

  A numeric giving the maximum step size in degrees for each movement.
  Default is 0.001.

- time_increment:

  A numeric giving the time between consecutive points in seconds.
  Default is 60 (1 minute).

- start_location:

  A numeric vector giving the starting location as c(easting, northing).
  Default is Vienna (16.3725042, 48.2083537).

- start_time:

  A POSIXct giving the starting time for the path. Default is current
  time.

- stay_prob:

  A numeric giving the probability of staying at the same location
  (0-1). Default is 0.2.

- format:

  A character string, either `"trackframe"` (easting/northing),
  `"data.frame"`, `"matrix"`, `"sftrack"` or `"move2"`.

## Value

Depending on the format argument either a `"trackframe"` or
`"data.frame"` or `"matrix"` or `"sftrack"` or `"move2"`.

## Examples

``` r
data <- sim_travel_path(100, format = "matrix")
```
