#smoove wrapper functions

#' Estimating parameters of unbiased CVM
#' 
#' This  function  estimates the mean speed \eqn{nu}, the time-scale \eqn{tau} and (occasionally) the initial speed \eqn{v_0} of the unbiased 
#' correlated velocity movement (UCVM).  See Gurarie et al. (2016) and the \code{vignette("smoove", package = "smoove")} vignette for more details. 
#' 
#' @param tf an object of class \code{track_frame}
#' @param method the method to use for the estimation.  These are (in increasing : velocity auto-correlation fitting (\code{vaf}), correlated 
#' random walk matching (\code{crw}), velocity likelihood (\code{vLike}), position likelihood (\code{zLike}) and position likelihood with Kalman 
#' filter (\code{crawl}). This last method is generally he best method, since it  fits the position likelihood more efficiently by using a Kalman 
#' filter. It is based on Johnson et al (2008) and is a wrapper for the \code{\link[crawl]{crwMLE}} in the (excellent) \code{\link[crawl]{crawl}} package.  
#' The default method is \code{vLike}.
#' @param parameters which parameters to estimate.  For most methods "tau" and "nu" are always both estimated, but some computation can be saved
#'  for the velocity likelihood method by providing an estimate for "nu".
#' @param CI whether or not to compute 95\% confidence intervals for parameters. In some cases, this can slow the computation down somewhat.
#' @param spline whether or not to use the spline correction (only relevant for \code{vaf} and \code{vLike}).
#' @param diagnose whether to draw a diagnostic plot.  Varies for different methods.
#' @param time.units unit of time to be passed to \code{\link[base]{difftime}()} to compute a relative numeric time vector.
#' @param ... additional parameters to pass to estimation functions.  These are particularly involved in the \code{crawl} method (see \code{\link[crawl]{crwMLE}}). 
#' @return A data frame with point estimates of mean speed `nu' and time-scale `tau' 
# #' @example demo/estimateUCVM_examples.R
#' @export
estimate_ucvm <- function(tf,
                          method = c("vaf", "crw", "vLike", "zLike", "crawl")[3],
                          parameters = c("tau", "nu"),
                          time.units = "min",
                          CI = TRUE,
                          spline = FALSE,
                          diagnose = TRUE,
                          ...) {
  checkmate::assert_class(tf, classes = "track_frame")
  fit <- smoove::estimateUCVM(
    Z = cbind(longitude(tf), latitude(tf)),
    T = as.POSIXct(index(tf)), #TODO as.POSIXct in Trackframe?
    method = method,
    parameters = parameters,
    time.units = time.units,
    CI = CI,
    spline = spline,
    diagnose = diagnose, 
    ...
  )
}

#' Autorcorrelation
#' 
#' applies acf
#'
#' @param tf an object of class \code{track_frame}
#'
#' @export
# #' @examples
diagnose_crw <- function(tf){
  checkmate::assert_class(tf, classes = "track_frame")
  # smoove:::DiagnoseCRW(cbind(longitude(tf), latitude(tf)))
  Z <- cbind(longitude(tf), latitude(tf))
  phi <- Arg(diff(Z))
  posjumps <- which(diff(phi) > pi)+1
  negjumps <- which(diff(phi) < -pi)+1
  l <- length(phi)
  for(i in posjumps)
    phi[i:l] <- phi[i:l]-2*pi
  for(i in negjumps)
    phi[i:l] <- phi[i:l]+2*pi
  theta <- diff(Arg(diff(Z)))
  theta[theta < pi] <- theta[theta < pi] + 2*pi
  theta[theta > pi] <- theta[theta > pi] - 2*pi
  
  
  # plot acf's
  par(mfrow=c(2,1), bty="l", cex.lab=1.25, mar=c(0,4,1,2), oma=c(4,0,4,0))
  acf(Mod(diff(Z)), main="", xaxt="n", xlab=""); mtext("Step length", line=0, cex=1.25, font=3)
  acf(theta, main=""); mtext("Turning angle", line=-1, cex=1.25, font=3)
  title("Autocorrelations should be near 0 at lag>0", outer=TRUE, font=2)
}


#' Estimate RACVM parameters
#'
#' Estimate rotational-advectice correlated velocity movement model 
#' 
#' This group of functions estimate the parameters of a rotational and advective CVM using a one-step velocity likelihood.  It is best implemented on relatively high resolution data from which one can obtain good estimates of velocity.  The observations can, however, be irregularly sampled.  
#' 
#' The parameterization is: \eqn{\tau} - characteristic time scale, \eqn{\mu} - advective velocity, \eqn{\eta} - random rms speed, \eqn{\omega} - angular speed. 
#' 
#' The \code{fitRACVM} function is an (internal) helper function. 
#' 
#' @param tf an object of class \code{track_frame}
#' @param model one of UCVM, RCVM, ACVM or RACVM. 
#' @param compare.models whether to compare four models: with both rotation and advection, only rotation, only advection, or neither.  The comparison provides a table with the log likelihood, number of parameters, AIC, BIC, delta AIC and delta BIC values.  A limited comparison set may be useful when running the fit many times (e.g. when performing change point analysis). 
#' @param modelset which models to fit and compare (if \code{compare.models}) is TRUE)
#' @param p0 optional named list of initial parameter values in the form: c(tau, eta, omega, mu.x, mu.y).
#' @param spline whether to implement the spline correction on the positions 
#' @param spline.res resolution of spline (see \code{\link[smoove]{getV.spline}})
#' @param T.spline new times for spline estimation (best left as NULL)
#' @param time.units time units of calculations (e.g. "sec", "min", "hour", "day")
#' @param verbose whether to output verbose message. defaults to FALSE#'
# #' @example demo/estimateRACVM_examples.R
#' @export
estimate_racvm <- function(tf,
                           model = "RACVM", 
                           compare.models = TRUE, 
                           modelset = c("UCVM", "ACVM", "RCVM", "RACVM"),
                           p0 = NULL, 
                           spline = FALSE,
                           spline.res = 1e-2,
                           T.spline= NULL,  
                           time.units = "min",
                           verbose = FALSE) {
  checkmate::assert_class(tf, classes = "track_frame")
  fit <- smoove::estimateRACVM(
    Z = cbind(longitude(tf), latitude(tf)), #T = index(tf),
    T = as.POSIXct(index(tf)),
    model = model,
    compare.models = compare.models,
    modelset = modelset,
    p0 = p0,
    spline = spline,
    spline.res = spline.res,
    T.spline = T.spline,
    time.units = time.units,
    verbose = verbose
  )
}


# IMPORTANT be aware time unit "mins" vs. "min" in other functions
# S3 method exists

#' Sweep RACVM 
#' 
#' Sets a window (a subset of movement data within specific time window), computes likelihoods for a set of candidate change points within the window, and steps the window forward, filling out a likelihood matrix. 
#' 
#' @param tf an object of class \code{track_frame}
#' @param model model to fit for the change point sweep - typically the most complex model in the candidate model set. 
#' @param windowsize time window of analysis to scan, IMPORTANTLY: in units of time (T).
#' @param windowstep step (in time) by which the window advances.  The smaller the step, the slower but more thorough the estimation. 
#' @param time.unit of the windowsize AND the windowstep. The default is "hours" - can be any of "secs", "mins", "hours", "days", "weeks" (See \code{\link[base]{difftime}}). Ignored if time is not POSIX. 
#' @param progress whether or not to show a progress bar
#' @param ... additional parameters to pass to the \code{\link{estimate_racvm}} function, notably the option "criterion" allows you to select models based on AIC or BIC (the former is more liberal with more complex models).
#' @param .parallel if set TRUE, will use \code{\link[foreach]{foreach}} to parallelize the optimization.  Requires establishing the 
#' @seealso \code{\link{plotWindowSweep}}, \code{\link{estimate_racvm}}, \code{\link{test_cp}}
# #' @example demo/sweepRACVM_examples.R
#' @export
sweep_racvm <- function(tf, windowsize = 1000, windowstep = 50, model='UCVM', progress = TRUE, time.unit = "mins", .parallel = FALSE, ...){
  checkmate::assert_class(tf, classes = "track_frame")
  smoove::sweepRACVM(
    Z = cbind(longitude(tf), latitude(tf)), #T = index(tf),
    T = as.POSIXct(index(tf)),
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time.unit = time.unit,
    .parallel = .parallel, ...)
}



#' Test RACVM change point
#' 
#' Identifies appropriate models on either side of a change point
#' 
#' @param tf an object of class \code{track_frame}
#' @param cp change point
#' @param start beginning time of segment to analyze
#' @param end end time of segment to analyze
#' @param modelset set of models to compare (combination of UCVM, ACVM, RCVM, RACVM, or \code{all}, which includes all of them)
#' @param spline whether or not to use the spline approximation for the final estimate. 
#' @param criterion selection criterion - either BIC or AIC (can be upper- or lowercased)
#' @param ... further params to \code{getFit} internal function
# #' @example ./demo/testCP_example.R
#' @export
test_cp <- function(tf, cp, start, end, modelset = "all", spline = FALSE, criterion = "BIC", ...){
  checkmate::assert_class(tf, classes = "track_frame")
  smoove::testCP(
    Z = cbind(longitude(tf), latitude(tf)), #T = index(tf),
    T = as.POSIXct(index(tf)),
    cp = cp,
    start = start,
    end = end,
    modelset = modelset,
    spline = spline,
    criterion = criterion,
    ...)
}