# Sweep RACVM

Sets a window (a subset of movement data within specific time window),
computes likelihoods for a set of candidate change points within the
window, and steps the window forward, filling out a likelihood matrix.

## Usage

``` r
sweep_racvm(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
)

# S3 method for class 'trackframe'
sweep_racvm(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
)

# S3 method for class 'data.frame'
sweep_racvm(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
)

# S3 method for class 'move2'
sweep_racvm(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
)

# S3 method for class 'sftrack'
sweep_racvm(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
)
```

## Arguments

- data:

  an object of class `trackframe`

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

- ...:

  additional parameters to pass to the
  [`estimate_racvm`](estimate_racvm.md) function, notably the option
  "criterion" allows you to select models based on AIC or BIC (the
  former is more liberal with more complex models).

## See also

`plotWindowSweep`, [`estimate_racvm`](estimate_racvm.md),
[`test_cp`](test_cp.md)
