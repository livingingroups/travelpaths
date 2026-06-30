# Estimate RACVM parameters

Estimate rotational-advectice correlated velocity movement model

## Usage

``` r
estimate_racvm(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 0.01,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
)

# S3 method for class 'trackframe'
estimate_racvm(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 0.01,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
)

# S3 method for class 'data.frame'
estimate_racvm(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 0.01,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
)

# S3 method for class 'move2'
estimate_racvm(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 0.01,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
)

# S3 method for class 'sftrack'
estimate_racvm(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 0.01,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
)
```

## Arguments

- data:

  an object of class `trackframe`

- model:

  one of UCVM, RCVM, ACVM or RACVM.

- compare_models:

  whether to compare four models: with both rotation and advection, only
  rotation, only advection, or neither. The comparison provides a table
  with the log likelihood, number of parameters, AIC, BIC, delta AIC and
  delta BIC values. A limited comparison set may be useful when running
  the fit many times (e.g. when performing change point analysis).

- modelset:

  which models to fit and compare (if `compare_models` is TRUE)

- p0:

  optional named list of initial parameter values in the form: c(tau,
  eta, omega, mu.x, mu.y).

- spline:

  whether to implement the spline correction on the positions

- spline_res:

  resolution of spline (see
  [`getV.spline`](https://rdrr.io/pkg/smoove/man/getV.spline.html))

- t_spline:

  new times for spline estimation (best left as NULL)

- time_units:

  time units of calculations (e.g. "secs", "mins", "hours", "days")

- verbose:

  whether to output verbose message. defaults to FALSE#'

## Details

This group of functions estimate the parameters of a rotational and
advective CVM using a one-step velocity likelihood. It is best
implemented on relatively high resolution data from which one can obtain
good estimates of velocity. The observations can, however, be
irregularly sampled.

The parameterization is: \\\tau\\ - characteristic time scale, \\\mu\\ -
advective velocity, \\\eta\\ - random rms speed, \\\omega\\ - angular
speed.

The `fitRACVM` function is an (internal) helper function.
