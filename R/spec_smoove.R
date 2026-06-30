# Smoove - Change Points

#' Find Change Points
#'
#' @param mode a character vector of length one, for the type of model. The only
#'   possible value for this model is "segmentation".
#' @param engine a character vector of length one, specifying what
#'   computational engine to use for fitting. Possible engines are listed
#'   below. The default for this model is `"smoove"`.
#' @param windowsize time window of analysis to scan, IMPORTANTLY: in units of time (T).
#' @param windowstep step (in time) by which the window advances. The smaller
#'   the step, the slower but more thorough the estimation.
#' @param time_unit of the windowsize AND the windowstep. The default is
#'   "hours" - can be any of "secs", "mins", "hours", "days", "weeks"
#'   (See \code{\link[base]{difftime}}). Ignored if time is not POSIX.
#' @param progress whether or not to show a progress bar
#' @param .parallel if set TRUE, will use \code{\link[foreach]{foreach}} to
#'   parallelize the optimization. Requires establishing the
#' @param model model to fit for the change point sweep - typically the most
#'   complex model in the candidate model set.
#' @param clusterwidth A time span within which very close change points are
#'   considered a single change point.
#' @param modelset set of models to compare (combination of UCVM, ACVM, RCVM,
#'   RACVM, or \code{all}, which includes all of them)
#' @param spline whether or not to use the spline approximation for the final estimate.
#' @param criterion selection criterion - either BIC or AIC (can be upper- or lowercased)
#' @param verbose a logical to control verbose output (default: \code{TRUE}).
#' @param output_col a character string giving the name of the output column
#'   added to the trackframe (default: \code{"phase_id"}).
#'
#' @return A trackframe with an additional column indicating change points.
#'
#' @examples
#' cvm_change_points()
#'
#' @rdname cvm_change_points
#' @export
cvm_change_points <- function(
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
) {
  args <- list(
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time_unit = time_unit,
    .parallel = .parallel,
    clusterwidth = clusterwidth,
    modelset = modelset,
    spline = spline,
    criterion = criterion,
    verbose = verbose,
    output_col = output_col
  )
  new_travelpath_spec(
    "cvm_change_points",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}
