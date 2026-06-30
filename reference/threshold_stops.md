# Threshold-based Stop Detection

\`threshold_stops()\` defines a model that identifies stops in movement
data based on distance and time thresholds. This method detects
stationary periods by grouping consecutive points that are within a
specified distance and time criteria.

There are different ways to fit this model, and the method of estimation
is chosen by setting the model engine. The engine-specific pages for
this model are listed below.

\-
[`infostop::identify_stops`](https://rdrr.io/pkg/infostop/man/identify_stops.html):
Threshold-based stop detection

## Usage

``` r
threshold_stops(
  mode = "segmentation",
  engine = "infostop",
  r1 = 10,
  min_size = 2L,
  min_staying_time = 300L,
  max_time_between = 86400L,
  output_col = "stop_id"
)
```

## Arguments

- mode:

  a character vector of length one, for the type of model. The only
  possible value for this model is "stops".

- engine:

  a character vector of length one, specifying what computational engine
  to use for fitting. Possible engines are listed below. The default for
  this model is \`"infostop"\`.

- r1:

  A positive numeric value giving the maximum distance between
  time-consecutive points to label them as stationary. Higher values
  will result in more points being considered stationary.

- min_size:

  A positive integer giving the minimum number of points required to
  consider a group stationary.

- min_staying_time:

  A positive integer giving the minimum duration (in seconds) that can
  constitute a stop. Only relevant if timestamps are provided in the
  data.

- max_time_between:

  A positive integer giving the maximum duration (in seconds) between
  consecutive points to consider them part of the same stop. Only
  relevant if timestamps are provided.

- output_col:

  a character vector of length one, specifying the name of the column to
  be used for the stop identifiers. Default is "stop_id".

## Value

A \`threshold_stops\` specification.

## Examples

``` r
threshold_stops()
#> $args
#> $args$r1
#> [1] 10
#> 
#> $args$min_size
#> [1] 2
#> 
#> $args$min_staying_time
#> [1] 300
#> 
#> $args$max_time_between
#> [1] 86400
#> 
#> $args$output_col
#> [1] "stop_id"
#> 
#> 
#> $eng_args
#> list()
#> 
#> $mode
#> [1] "segmentation"
#> 
#> $method
#> NULL
#> 
#> $engine
#> [1] "infostop"
#> 
#> attr(,"class")
#> [1] "threshold_stops" "travelpath_spec"

# Specify distance metric and parameters
ths_spec <- threshold_stops(
  r1 = 20,
  min_size = 3
)
```
