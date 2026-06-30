# Find Change Points

Find Change Points

## Usage

``` r
cvm_change_points(
  mode = "segmentation",
  engine = "smoove",
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  clusterwidth = NULL,
  modelset = "all",
  spline = TRUE,
  criterion = "BIC",
  verbose = TRUE,
  output_col = "phase_id"
)
```

## Arguments

- mode:

  a character vector of length one, for the type of model. The only
  possible value for this model is "segmentation".

- engine:

  a character vector of length one, specifying what computational engine
  to use for fitting. Possible engines are listed below. The default for
  this model is \`"smoove"\`.

- windowsize:

  time window of analysis to scan, IMPORTANTLY: in units of time (T).

- windowstep:

  step (in time) by which the window advances. The smaller the step, the
  slower but more thorough the estimation.

- model:

  model to fit for the change point sweep - typically the most complex
  model in the candidate model set.

- progress:

  whether or not to show a progress bar

- time_unit:

  of the windowsize AND the windowstep. The default is "hours" - can be
  any of "secs", "mins", "hours", "days", "weeks" (See
  [`difftime`](https://rdrr.io/r/base/difftime.html)). Ignored if time
  is not POSIX.

- .parallel:

  if set TRUE, will use
  [`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html) to
  parallelize the optimization. Requires establishing the

- clusterwidth:

  A time span within which very close change points are considered a
  single change point.

- modelset:

  set of models to compare (combination of UCVM, ACVM, RCVM, RACVM, or
  `all`, which includes all of them)

- spline:

  whether or not to use the spline approximation for the final estimate.

- criterion:

  selection criterion - either BIC or AIC (can be upper- or lowercased)

- verbose:

  a logical to control verbose output (default: `TRUE`).

- output_col:

  a character string giving the name of the output column added to the
  trackframe (default: `"phase_id"`).

## Value

A trackframe with an additional column indicating change points.

## Examples

``` r
cvm_change_points()
#> $args
#> $args$windowsize
#> [1] 1000
#> 
#> $args$windowstep
#> [1] 50
#> 
#> $args$model
#> [1] "UCVM"
#> 
#> $args$progress
#> [1] TRUE
#> 
#> $args$time_unit
#> [1] "mins"
#> 
#> $args$.parallel
#> [1] FALSE
#> 
#> $args$clusterwidth
#> NULL
#> 
#> $args$modelset
#> [1] "all"
#> 
#> $args$spline
#> [1] TRUE
#> 
#> $args$criterion
#> [1] "BIC"
#> 
#> $args$verbose
#> [1] TRUE
#> 
#> $args$output_col
#> [1] "phase_id"
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
#> [1] "smoove"
#> 
#> attr(,"class")
#> [1] "cvm_change_points" "travelpath_spec"  
```
