#smoove wrapper functions
#' Title
#'
#' @param tf 
#' @param time.units 
#' @param diagnose 
#' @param CI 
#' @param method 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
estimate_ucvm <- function(tf, time.units = "min", diagnose = TRUE,  CI = TRUE, method = "crw", ...) {
  checkmate::check_class(tf, classes = "track_frame")
  fit <- smoove::estimateUCVM(
    Z = cbind(longitude(tf), latitude(tf)),
    T = as.POSIXct(index(tf)), #TODO as.POSIXct in Trackframe?
    time.units = time.units,
    diagnose = diagnose,  CI = CI, method = method ,...
  )
}

#' Title
#'
#' @param tf 
#'
#' @return
#' @export
#'
#' @examples
diagnose_crw <- function(tf){
  checkmate::check_class(tf, classes = "track_frame")
  smoove:::DiagnoseCRW(cbind(longitude(tf), latitude(tf)))
}


#' Title
#'
#' @param tf 
#' @param time.units 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
estimate_racvm <- function(tf, time.units = "min", ...) {
  checkmate::check_class(tf, classes = "track_frame")
  fit <- smoove::estimateRACVM(
    Z = cbind(longitude(tf), latitude(tf)), #T = index(tf),
    T = as.POSIXct(index(tf)),
    time.units = time.units ,...
  )
}


# IMPORTANT be aware time unit "mins" vs. "min" in other functions
# S3 method exists

#' Title
#'
#' @param tf 
#' @param windowsize 
#' @param windowstep 
#' @param model 
#' @param time.unit 
#' @param .parallel 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
sweep_racvm <- function(tf, windowsize = 1000, windowstep = 50, model='UCVM', time.unit = "mins", .parallel = FALSE, ...){
  checkmate::check_class(tf, classes = "track_frame")
  smoove::sweepRACVM(
    Z = cbind(longitude(tf), latitude(tf)), #T = index(tf),
    T = as.POSIXct(index(tf)),
    windowsize = windowsize, windowstep = windowstep,
    model = model, time.unit = time.unit, .parallel = .parallel, ...)
}