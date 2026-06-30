# Generate Multiple Random Travel Paths

This function creates multiple random travel paths and combines them
into a single object. Each path is assigned coordinates
(easting/northing for format trackframe and northing/easting else) and
time values and a unique track ID. Each path can include stationary
periods and movements with configurable parameters. The following output
formats are supported: `"trackframe"` (easting/northing),
`"data.frame"`, `"matrix"`, `"sftrack"` or `"move2"`.

## Usage

``` r
sim_travel_paths(
  ntracks,
  sizes,
  max_step = 0.001,
  time_increment = 60,
  start_location = c(16.3725042, 48.2083537),
  start_time = as.POSIXct(format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  stay_prob = 0.2,
  track_prefix = "track",
  format = c("trackframe", "data.frame", "matrix", "sftrack", "move2")
)
```

## Arguments

- ntracks:

  An integer specifying the number of tracks to generate.

- sizes:

  An integer vector specifying the number of points for each track. If a
  single value is provided, it will be repeated for all tracks.

- max_step:

  A numeric value specifying the maximum step size for random movements.
  Default is 0.001 (approximately 100m at the equator).

- time_increment:

  A numeric giving the time between consecutive points in seconds.
  Default is 60 (1 minute).

- start_location:

  A numeric vector giving the starting location as c(easting, northing).
  Default is Vienna (16.3725042, 48.2083537)

- start_time:

  A POSIXct giving the starting time for the paths. Default is current
  time.

- stay_prob:

  A numeric between 0 and 1 giving the probability of staying at the
  same location. Default is 0.2.

- track_prefix:

  A character string used as a prefix for track IDs. Default is "track".
  Track IDs will be formatted as `prefix\_number`.

- format:

  A character string, either `"trackframe"` (easting/northing),
  `"data.frame"`, `"matrix"`, `"sftrack"` or `"move2"`.

## Value

Depending on the format argument either a `"trackframe"` or
`"data.frame"` or `"matrix"` or `"sftrack"` or `"move2"`.

## Examples

``` r
# Generate 3 tracks with different sizes
ntracks <- 3
sizes <- c(2, 4, 5)
multi_track <- sim_travel_paths(ntracks, sizes)
#> Error in as.trackframe.sf(data, time_col = time_col, easting_col = easting_col,     northing_col = northing_col, id_col = id_col, sort = sort,     coerce_to = coerce_to, ...): Column easting set as sf_easting_col, but exists also in data.
#>       Remove column easting in data, or change sf_easting_col using tf_options()

# Generate 5 tracks all with the same size
uniform_tracks <- sim_travel_paths(5, 10)
#> Error in as.trackframe.sf(data, time_col = time_col, easting_col = easting_col,     northing_col = northing_col, id_col = id_col, sort = sort,     coerce_to = coerce_to, ...): Column easting set as sf_easting_col, but exists also in data.
#>       Remove column easting in data, or change sf_easting_col using tf_options()

# Extract a specific track
track2 <- select_id(multi_track, "track_2")
#> Error: object 'multi_track' not found
```
