# Estimating parameters of unbiased CVM

This function estimates the mean speed \\nu\\, the time-scale \\tau\\
and (occasionally) the initial speed \\v_0\\ of the unbiased correlated
velocity movement (UCVM). See Gurarie et al. (2016) and the
`vignette("smoove", package = "smoove")` vignette for more details.

## Usage

``` r
estimate_ucvm(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
)

# S3 method for class 'trackframe'
estimate_ucvm(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
)

# S3 method for class 'data.frame'
estimate_ucvm(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
)

# S3 method for class 'move2'
estimate_ucvm(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
)

# S3 method for class 'sftrack'
estimate_ucvm(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
)
```

## Arguments

- data:

  an object coercible to class `trackframe`

- method:

  the method to use for the estimation. These are (in increasing):
  velocity auto-correlation fitting (`vaf`), correlated random walk
  matching (`crw`), velocity likelihood (`vLike`), position likelihood
  (`zLike`) and position likelihood with Kalman filter (`crawl`). This
  last method is generally the best method, since it fits the position
  likelihood more efficiently by using a Kalman filter. It is based on
  Johnson et al (2008) and is a wrapper for the
  [`crwMLE`](https://rdrr.io/pkg/crawl/man/crwMLE.html) in the
  [`crawl`](https://rdrr.io/pkg/crawl/man/crawl-package.html) package.
  The default method is `vLike`.

- parameters:

  which parameters to estimate. For most methods "tau" and "nu" are
  always both estimated, but some computation can be saved for the
  velocity likelihood method by providing an estimate for "nu".

- time_units:

  unit of time to be passed to
  [`difftime()`](https://rdrr.io/r/base/difftime.html) to compute a
  relative numeric time vector.

- ci:

  whether or not to compute 95% confidence intervals for parameters. In
  some cases, this can slow the computation down somewhat.

- spline:

  whether or not to use the spline correction (only relevant for `vaf`
  and `vLike`).

- diagnose:

  whether to draw a diagnostic plot. Varies for different methods.

- ...:

  additional parameters to pass to estimation functions. These are
  particularly involved in the `crawl` method (see
  [`crwMLE`](https://rdrr.io/pkg/crawl/man/crwMLE.html)).

## Value

A data frame with point estimates of mean speed \`nu\` and time-scale
\`tau\`
