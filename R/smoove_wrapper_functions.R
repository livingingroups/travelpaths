# Smoove wrapper functions

#' Estimating parameters of unbiased CVM
#'
#' This function estimates the mean speed \eqn{nu}, the time-scale \eqn{tau}
#'   and (occasionally) the initial speed \eqn{v_0} of the unbiased correlated
#'   velocity movement (UCVM). See Gurarie et al. (2016) and the
#'   \code{vignette("smoove", package = "smoove")} vignette for more details.
#'
#' @param data an object coercible to class \code{trackframe}
#' @param method the method to use for the estimation. These are (in
#'   increasing): velocity auto-correlation fitting (\code{vaf}), correlated
#'   random walk matching (\code{crw}), velocity likelihood (\code{vLike}),
#'   position likelihood (\code{zLike}) and position likelihood with Kalman
#'   filter (\code{crawl}). This last method is generally the best method,
#'   since it fits the position likelihood more efficiently by using a Kalman
#'   filter. It is based on Johnson et al (2008) and is a wrapper for the
#'   \code{\link[crawl]{crwMLE}} in the \code{\link[crawl]{crawl}} package.
#'   The default method is \code{vLike}.
#' @param parameters which parameters to estimate. For most methods "tau" and
#'   "nu" are always both estimated, but some computation can be saved for the
#'   velocity likelihood method by providing an estimate for "nu".
#' @param ci whether or not to compute 95\% confidence intervals for
#'   parameters. In some cases, this can slow the computation down somewhat.
#' @param spline whether or not to use the spline correction (only relevant for
#'   \code{vaf} and \code{vLike}).
#' @param diagnose whether to draw a diagnostic plot. Varies for different
#'   methods.
#' @param time_units unit of time to be passed to
#'   \code{\link[base]{difftime}()} to compute a relative numeric time vector.
#' @param ... additional parameters to pass to estimation functions. These are
#'   particularly involved in the \code{crawl} method (see
#'   \code{\link[crawl]{crwMLE}}).
#' @return A data frame with point estimates of mean speed `nu` and time-scale
#'   `tau`
# @example demo/estimateUCVM_examples.R
#' @export
#' @rdname estimate_ucvm
estimate_ucvm <- function(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
) {
  UseMethod("estimate_ucvm")
}

#' @rdname estimate_ucvm
#' @export
estimate_ucvm.trackframe <- function(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
) {
  # checkmate::assert_class(data, classes = "trackframe")
  fit <- smoove::estimateUCVM(
    Z = cbind(easting(data), northing(data)),
    T = as.POSIXct(time(data)),
    method = method,
    parameters = parameters,
    time.units = time_units,
    CI = ci,
    spline = spline,
    diagnose = diagnose,
    ...
  )
  return(fit)
}


#' @export
#' @rdname estimate_ucvm
estimate_ucvm.data.frame <- function(
  data,
  method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
  parameters = c("tau", "nu"),
  time_units = "mins",
  ci = FALSE,
  spline = FALSE,
  diagnose = TRUE,
  ...
) {
  estimate_ucvm.trackframe(
    as.trackframe(data),
    method = method,
    parameters = parameters,
    time_units = time_units,
    ci = ci,
    spline = spline,
    diagnose = diagnose
  )
}


#' @export
#' @rdname estimate_ucvm
estimate_ucvm.move2 <- estimate_ucvm.data.frame


#' @export
#' @rdname estimate_ucvm
estimate_ucvm.sftrack <- estimate_ucvm.data.frame

#' Autorcorrelation
#'
#' applies acf
#'
#' @param data an object coercible to class \code{trackframe}
#'
#' @export
#' @rdname diagnose_crw
diagnose_crw <- function(data) {
  UseMethod("diagnose_crw")
}

#' @export
#' @rdname diagnose_crw
diagnose_crw.trackframe <- function(data) {
  checkmate::assert_class(data, classes = "trackframe")
  # smoove:::DiagnoseCRW(cbind(easting(data), northing(data)))
  z <- cbind(easting(data), northing(data))
  phi <- Arg(diff(z))
  posjumps <- which(diff(phi) > pi) + 1
  negjumps <- which(diff(phi) < -pi) + 1
  l <- length(phi)
  for (i in posjumps) {
    phi[i:l] <- phi[i:l] - 2 * pi
  }
  for (i in negjumps) {
    phi[i:l] <- phi[i:l] + 2 * pi
  }
  theta <- diff(Arg(diff(z)))
  theta[theta < pi] <- theta[theta < pi] + 2 * pi
  theta[theta > pi] <- theta[theta > pi] - 2 * pi

  # plot acf's
  par(mfrow = c(2, 1), bty = "l", cex.lab = 1.25, mar = c(0, 4, 1, 2), oma = c(4, 0, 4, 0))
  acf(Mod(diff(z)), main = "", xaxt = "n", xlab = "")
  mtext("Step length", line = 0, cex = 1.25, font = 3)
  acf(theta, main = "")
  mtext("Turning angle", line = -1, cex = 1.25, font = 3)
  title("Autocorrelations should be near 0 at lag>0", outer = TRUE, font = 2)
}

#' @export
#' @rdname diagnose_crw
diagnose_crw.data.frame <- function(data) {
  diagnose_crw.trackframe(as.trackframe(data))
}


#' @export
#' @rdname diagnose_crw
diagnose_crw.move2 <- diagnose_crw.data.frame


#' @export
#' @rdname diagnose_crw
diagnose_crw.sftrack <- diagnose_crw.data.frame


#' Estimate RACVM parameters
#'
#' Estimate rotational-advectice correlated velocity movement model
#'
#' This group of functions estimate the parameters of a rotational and
#'   advective CVM using a one-step velocity likelihood. It is best
#'   implemented on relatively high resolution data from which one can obtain
#'   good estimates of velocity. The observations can, however, be irregularly
#'   sampled.
#'
#' The parameterization is: \eqn{\tau} - characteristic time scale,
#'   \eqn{\mu} - advective velocity,
#' \eqn{\eta} - random rms speed, \eqn{\omega} - angular speed.
#'
#' The \code{fitRACVM} function is an (internal) helper function.
#'
#' @param data an object of class \code{trackframe}
#' @param model one of UCVM, RCVM, ACVM or RACVM.
#' @param compare_models whether to compare four models: with both rotation
#'   and advection, only rotation, only advection, or neither. The comparison
#'   provides a table with the log likelihood, number of parameters, AIC, BIC,
#'   delta AIC and delta BIC values. A limited comparison set may be useful
#'   when running the fit many times (e.g. when performing change point
#'   analysis).
#' @param modelset which models to fit and compare (if
#'   \code{compare_models} is TRUE)
#' @param p0 optional named list of initial parameter values in the form:
#'   c(tau, eta, omega, mu.x, mu.y).
#' @param spline whether to implement the spline correction on the positions
#' @param spline_res resolution of spline (see
#'   \code{\link[smoove]{getV.spline}})
#' @param t_spline new times for spline estimation (best left as NULL)
#' @param time_units time units of calculations (e.g. "secs", "mins",
#'   "hours", "days")
#' @param verbose whether to output verbose message. defaults to FALSE#'
#  @example demo/estimateRACVM_examples.R
#' @export
#' @rdname estimate_racvm
estimate_racvm <- function(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 1e-2,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
) {
  UseMethod("estimate_racvm")
}

#' @export
#' @rdname estimate_racvm
estimate_racvm.trackframe <- function(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 1e-2,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
) {
  checkmate::assert_class(data, classes = "trackframe")
  fit <- smoove::estimateRACVM(
    Z = cbind(easting(data), northing(data)),
    T = as.POSIXct(time(data)),
    model = model,
    compare.models = compare_models,
    modelset = modelset,
    p0 = p0,
    spline = spline,
    spline.res = spline_res,
    T.spline = t_spline,
    time.units = time_units,
    verbose = verbose
  )
  return(fit)
}


#' @export
#' @rdname estimate_racvm
estimate_racvm.data.frame <- function(
  data,
  model = "RACVM",
  compare_models = TRUE,
  modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
  p0 = NULL,
  spline = FALSE,
  spline_res = 1e-2,
  t_spline = NULL,
  time_units = "mins",
  verbose = FALSE
) {
  estimate_racvm.trackframe(
    as.trackframe(data),
    model = model,
    compare_models = compare_models,
    modelset = modelset,
    p0 = p0,
    spline = spline,
    spline_res = spline_res,
    t_spline = t_spline,
    time_units = time_units,
    verbose = verbose
  )
}


#' @export
#' @rdname estimate_racvm
estimate_racvm.move2 <- estimate_racvm.data.frame


#' @export
#' @rdname estimate_racvm
estimate_racvm.sftrack <- estimate_racvm.data.frame


# IMPORTANT be aware time unit "mins" vs. "min" in other functions
# S3 method exists

#' Sweep RACVM
#'
#' Sets a window (a subset of movement data within specific time window),
#'   computes likelihoods for a set of candidate change points within the
#'   window, and steps the window forward, filling out a likelihood matrix.
#'
#' @param data an object of class \code{trackframe}
#' @param model model to fit for the change point sweep - typically the most
#'   complex model in the candidate model set.
#' @param windowsize time window of analysis to scan, IMPORTANTLY: in units of
#'   time (T).
#' @param windowstep step (in time) by which the window advances. The smaller
#'   the step, the slower but more thorough the estimation.
#' @param time_unit of the windowsize AND the windowstep. The default is
#'   "hours" - can be any of "secs", "mins", "hours", "days", "weeks" (See
#'   \code{\link[base]{difftime}}). Ignored if time is not POSIX.
#' @param progress whether or not to show a progress bar
#' @param ... additional parameters to pass to the \code{\link{estimate_racvm}}
#'   function, notably the option "criterion" allows you to select models based
#'   on AIC or BIC (the former is more liberal with more complex models).
#' @param .parallel if set TRUE, will use \code{\link[foreach]{foreach}} to
#'   parallelize the optimization. Requires establishing the
#' @seealso \code{\link{plotWindowSweep}}, \code{\link{estimate_racvm}},
#'   \code{\link{test_cp}}
#  @example demo/sweepRACVM_examples.R
#' @export
#' @rdname sweep_racvm
sweep_racvm <- function(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
) {
  UseMethod("sweep_racvm")
}


# sweepRACVM does later
# T <- as.numeric(difftime(T.raw, T.raw[1], units = time.unit))
# cut.wstep <- cut(T, c(seq(min(T), max(T) - windowsize, windowstep),
#                  max(T) + 1), include.lowest = TRUE, labels = FALSE)
# if the timestamps, time_unit and windowsize do not fit together
# this gives an error since it dispatches to something like
# seq.default(from = 1, to = -10, by = 3) and gives a "wrong sign in 'by' argument"
# error.
assert_windowsize <- function(timestamps, windowsize, time_unit) {
  timedelta <- as.numeric(difftime(timestamps, timestamps[1], units = time_unit))
  seq_from <- min(timedelta, na.rm = TRUE)
  seq_to <- (max(timedelta, na.rm = TRUE) - windowsize)
  if ((seq_to <= 0) || (seq_to <= seq_from)) {
    emsg <- "The choosen time_unit and windowsize do not fit to the available data."
    stop(emsg, call. = FALSE)
  }
}


#' @export
#' @rdname sweep_racvm
sweep_racvm.trackframe <- function(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
) {
  checkmate::assert_class(data, classes = "trackframe")

  if (.parallel == TRUE) {
    stop(".parallel needs to be fixed in smoove::sweepRACVM")
  }

  xtime <- as.POSIXct(time(data))
  assert_windowsize(xtime, windowsize = windowsize, time_unit = time_unit)

  smoove::sweepRACVM(
    Z = cbind(easting(data), northing(data)),
    T = xtime,
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time.unit = time_unit,
    .parallel = .parallel,
    ...
  )
}


#' @export
#' @rdname sweep_racvm
sweep_racvm.data.frame <- function(
  data,
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  ...
) {
  sweep_racvm.trackframe(
    as.trackframe(data),
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time_unit = time_unit,
    .parallel = .parallel,
    ...
  )
}


#' @export
#' @rdname sweep_racvm
sweep_racvm.move2 <- sweep_racvm.data.frame


#' @export
#' @rdname sweep_racvm
sweep_racvm.sftrack <- sweep_racvm.data.frame


#' Test RACVM change point
#'
#' Identifies appropriate models on either side of a change point
#'
#' @param data an object of class \code{trackframe}
#' @param cp change point
#' @param start beginning time of segment to analyze
#' @param end end time of segment to analyze
#' @param modelset set of models to compare (combination of UCVM, ACVM, RCVM,
#'   RACVM, or \code{all}, which includes all of them)
#' @param spline whether or not to use the spline approximation for the final
#'   estimate.
#' @param criterion selection criterion - either BIC or AIC (can be upper- or
#'   lowercased)
#' @param time_units time units of calculations (e.g. "secs", "mins",
#'   "hours", "days")
#' @param ... further params to \code{getFit} internal function
#' @examples
#' tf <- sim_travel_path(1000, format = "trackframe")
#' test_cp(tf, 10, 1, 100)
#' @export
#' @rdname test_cp
test_cp <- function(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
) {
  UseMethod("test_cp")
}

#' @export
#' @rdname test_cp
test_cp.trackframe <- function(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
) {
  checkmate::assert_class(data, classes = "trackframe")
  smoove::testCP(
    Z = easting(data) + 1i * northing(data),
    T = as.numeric(difftime(time(data), time(data)[1], units = time_units)),
    cp = cp,
    start = start,
    end = end,
    modelset = modelset,
    spline = spline,
    criterion = criterion,
    ...
  )
}


#' @export
#' @rdname test_cp
test_cp.data.frame <- function(
  data,
  cp,
  start,
  end,
  modelset = "all",
  spline = FALSE,
  criterion = "BIC",
  time_units = "mins",
  ...
) {
  test_cp.trackframe(
    as.trackframe(data),
    cp = cp,
    start = start,
    end = end,
    modelset = modelset,
    spline = spline,
    criterion = criterion,
    time_units = time_units,
    ...
  )
}


#' @export
#' @rdname test_cp
test_cp.move2 <- test_cp.data.frame


#' @export
#' @rdname test_cp
test_cp.sftrack <- test_cp.data.frame


#' Find single change point
#'
#' Finds a single change point in UCVM parameters (time scale \eqn{tau} and rms
#' speed \eqn{eta}) of a movement.
#'
#' @details Two methods are provided: "sweep", which scans a set of possible
#' change points, smooths the likelihoods and selects the maximum, or "optimize"
#' which uses R's single dimension optimization algorithms to find the most
#' likely change point. The latter is faster, but can be unreliable because the
#' likelihood profiles are typically quite rough.
#'
#'
#' @param data an object of class \code{trackframe}
#' @param k tuning parameter for the smoothing of the likelihood profile spline.
#'   The number of knots is "length(T)/4 * k" - the lower the value of k, the
#'   smoother the spline.
#' @param method one of "sweep" or "optimize". See details.
#' @param plotme whether to plot the resulting likelihood (only if method is
#'   "sweep").
#' @param time_units time units of calculations (e.g. "secs", "mins",
#'   "hours", "days")
#' @param ... additional parameters to pass to
#'   \code{\link{estimateUCVM}} function, in particular the method of
#'   estimation. Under most conditions, fairly reliable and fast results are
#'   provided
#' by the default \code{vLike} (velocity likelihood) method.
#'
#' @examples
#' set.seed(2025)
#' tf <- sim_travel_path(50, format = "trackframe")
#' find_single_break_point(tf, method = "sweep")
#' find_single_break_point(tf, method = "optimize")
#' @export
#' @rdname find_single_break_point
find_single_break_point <- function(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
) {
  UseMethod("find_single_break_point")
}


#' @export
#' @rdname find_single_break_point
find_single_break_point.trackframe <- function(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
) {
  checkmate::assert_class(data, classes = "trackframe")
  smoove::findSingleBreakPoint(
    Z = easting(data) + 1i * northing(data),
    T = as.numeric(difftime(time(data), time(data)[1], units = time_units)),
    k = k,
    method = method,
    plotme = plotme,
    ...
  )
}


#' @export
#' @rdname find_single_break_point
find_single_break_point.data.frame <- function(
  data,
  k = 1,
  method = "sweep",
  plotme = TRUE,
  time_units = "mins",
  ...
) {
  find_single_break_point.trackframe(
    as.trackframe(data),
    k = k,
    method = method,
    plotme = plotme,
    time_units = time_units,
    ...
  )
}


#' @export
#' @rdname find_single_break_point
find_single_break_point.move2 <- find_single_break_point.data.frame


#' @export
#' @rdname find_single_break_point
find_single_break_point.sftrack <- find_single_break_point.data.frame

#' Plot Phases
#'
#' @param x an object of class trackframe containing a cvm phases object in
#'   the attributes or a phase list
#' @param cols colors for phases (by default uses the `rich.colors` palette
#'   from `gplots`)
#' @param plot.parameters whether the parameters are plotted
#' @param parameters which parameters to plot (by default - ALL of the
#'   estimated parameters)
#' @param plot_legend whether to plot a legend
#' @param legend_where location of legend
#' @param layout "horizontal" (default) or "vertical" - as preferred (partial
#'   string matching accepted)
#'
#' @export
plot_phases <- function(
  x,
  cols = NULL,
  plot.parameters = TRUE,
  parameters = NULL,
  plot_legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
) {
  UseMethod("plot_phases")
}

#' @export
plot_phases.list <- function(
  x,
  cols = NULL,
  plot.parameters = TRUE,
  parameters = NULL,
  plot_legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
) {
  if (is.null(cols)) cols <- gplots::rich.colors(length(x))
  smoove::plotPhaseList(
    x,
    cols = cols,
    plot.parameters = plot.parameters,
    parameters = parameters,
    plot.legend = plot_legend,
    legend.where = legend_where,
    layout = layout)
}

#' @export
plot_phases.trackframe <- function(
  x,
  cols = NULL,
  plot.parameters = TRUE,
  parameters = NULL,
  plot_legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
) {
  phase_list <- attr(x, "cvm_phases")
  if (is.null(phase_list)) stop("no cvm_phases available in trackframe")
  if (is.null(cols)) cols <- gplots::rich.colors(length(phase_list))
  smoove::plotPhaseList(
    phase_list,
    cols = cols,
    plot.parameters = plot.parameters,
    parameters = parameters,
    plot.legend = plot_legend,
    legend.where = legend_where,
    layout = layout)
}

#' Summarize phases
#'
#' Takes a phase list and obtains a tidy table of point estimates of
#'   relevant parameters.
#'
#' @param x an object of class trackframe containing a cvm phases object in
#'   the attributes or a phase list
#'
#' @export
summarize_phases <- function(x) {
  UseMethod("summarize_phases")
}

#' @export
summarize_phases.list <- function(x) {
  smoove::summarizePhases(x)
}

#' @export
summarize_phases.trackframe <- function(x) {
  phase_list <- attr(x, "cvm_phases")
  if (is.null(phase_list)) stop("no cvm_phases available in trackframe")
  smoove::summarizePhases(phase_list)
}
