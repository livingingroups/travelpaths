#' Find Candidate Change Points
#'
#' A slightly modified version of smoove::findCandidateChangePoints. Also stores the minimum
#' clusterwidth in the attributes of the output.
#'
#' @details The raw output of the window sweep (\code{\link{sweepRACVM}})
#'
#' @param windowsweep A windowsweep object (matrix), output of \code{\link{sweepRACVM}} function
#' @param clusterwidth A time span within which very close change points are considered a single chagne point.
#' @param verbose Whether or not to report the number of change points that are clustered away.
#' @examples
#' library(smoove)
#' library(travelpaths)
#' data(simSweep,package = "smoove")
#' # The warning lets us know that some of the candidate change points
#' # are rather too close (in time) to each other
#' cp_all <- travelpaths:::find_candidate_change_points(windowsweep = simSweep, clusterwidth = 0)
#' as.vector(cp_all)
#' cp_cl <- travelpaths:::find_candidate_change_points(windowsweep = simSweep, clusterwidth = 4)
#' as.vector(cp_cl)
find_candidate_change_points <- function(
  windowsweep,
  clusterwidth = 0,
  verbose = TRUE
) {
  t_raw <- attr(windowsweep, "time")
  time_unit <- attr(windowsweep, "time.unit")

  if (inherits(t_raw, "POSIXt")) {
    time <- as.numeric(difftime(t_raw, t_raw[1], units = time_unit))
  } else {
    time <- t_raw
  }

  candidate_cps <- sort(unlist(unique(apply(windowsweep, 2, function(ll) {
    time[which.max(ll)]
  }))))
  n_raw <- length(candidate_cps)

  if (clusterwidth > 0) {
    candidate_cps <- sapply(clusters(rep(candidate_cps, 2), clusterwidth), mean)
  } else {
    candidate_cps <- unique(candidate_cps)
  }

  candidate_cps <- sort(candidate_cps)
  n_new <- length(candidate_cps)

  if (verbose) {
    message(paste(
      "Note: clustering candidate change points at",
      clusterwidth,
      "time units collapsed",
      n_raw,
      "candidate change points to",
      n_new,
      "change points.",
      collapse = " "
    ))
  }

  # compute number of points per segmen
  d_times <- table(cut(
    time,
    c(time[1] - 1, candidate_cps, time[length(time)] + 1)
  ))
  n_min <- min(d_times)
  if (n_min < 5) {
    wmsg <- sprintf(
      "%s %s %s.",
      "Some of your partitions are very small - probably too small.",
      "You might consider re-clustering the change points with a threshold of at least",
      paste(signif(min(diff(candidate_cps)), 3))
    )
    wmsg <- paste(
      strwrap(wmsg, width = getOption("width") - 4, prefix = "   "),
      collapse = "\n"
    )
    warning(wmsg)
    attr(candidate_cps, "min_clusterwidth") <- signif(
      min(diff(candidate_cps)),
      3
    )
  }
  allunits <- c("secs", "mins", "hours", "days", "weeks")
  allfactors <- c(1, 60, 60 * 60, 60 * 60 * 24, 60 * 60 * 24 * 7)

  if (inherits(t_raw, "POSIXt")) {
    candidate_cps <- t_raw[1] +
      candidate_cps * allfactors[match(time_unit, allunits)]
  }

  attr(candidate_cps, "time_unit") <- time_unit
  attr(candidate_cps, "time") <- t_raw
  attr(candidate_cps, "Z") <- attributes(windowsweep)$Z

  return(candidate_cps)
}


#' @param data currently a trackframe
#' @param ... ...
#' @export
#' @rdname cvm_change_points
cvm_estimate_change_points <- function(
  data,
  cp_id_col = "cp_id",
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
  ...
) {
  # NOTE: implement S3 method also for sftrack, move2 and ?data.frame
  checkmate::assert_class(data, classes = "trackframe")
  checkmate::assert_numeric(clusterwidth, null.ok = TRUE, lower = 0)

  k_sweep <- sweep_racvm(
    data,
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time_unit = time_unit,
    .parallel = .parallel,
    ...
  )

  if (is.null(clusterwidth)) {
    clusterwidth_i <- 1
    cpts <- suppressWarnings(find_candidate_change_points(
      windowsweep = k_sweep,
      clusterwidth = clusterwidth_i,
      verbose = verbose
    ))
    while (!is.null(attr(cpts, "min_clusterwidth"))) {
      clusterwidth_i <- attr(cpts, "min_clusterwidth")
      cpts <- suppressWarnings(find_candidate_change_points(
        windowsweep = k_sweep,
        clusterwidth = clusterwidth_i,
        verbose = verbose
      ))
    }
    # FIXME: @RH what should we do with the sprintf below ?
    # sprintf("clusterwidth set to %i", clusterwidth_i)
  } else {
    cpts <- smoove::findCandidateChangePoints(
      windowsweep = k_sweep,
      clusterwidth = clusterwidth,
      verbose = verbose
    )
  }
  cp_table <- smoove::getCPtable(
    CPs = cpts,
    modelset = modelset,
    spline = spline,
    criterion = criterion
  )
  # NOTE: multitrack not supported here
  data[cp_id_col] <- 0
  idx <- time(data) %in% cp_table$CP
  data[idx, cp_id_col] <- 1
  data[idx, cp_id_col] <- cumsum(data[idx, cp_id_col]) * data[idx, cp_id_col]
  attr(data, "cvm_cp_table") <- cp_table
  return(data)
}


#' @param data currently a trackframe
#' @export
#' @rdname cvm_phases
cvm_estimate_phases <- function(
  data,
  criterion = "BIC",
  verbose = TRUE,
  phase_id_col = "phase_id"
) {
  # NOTE: implement S3 method also for sftrack, move2 and ?data.frame
  checkmate::assert_class(data, classes = "trackframe")
  cp_table <- attr(data, "cvm_cp_table")

  # estimatePhases
  cvm_phases <- smoove::estimatePhases(
    cp_table,
    criterion = criterion,
    verbose = verbose
  )
  names(cvm_phases) <- as.integer(as.roman(names(cvm_phases)))
  idx_phases <- lapply(cvm_phases, function(x) {
    which(time(data) >= x$start & time(data) < x$end)
  })

  data[phase_id_col] <- NA
  data[unlist(idx_phases, use.names = FALSE), phase_id_col] <- rep(
    names(idx_phases),
    times = lengths(idx_phases)
  )

  attr(data, "cvm_phases") <- cvm_phases
  attr(data, "summary_cvm_phases") <- smoove::summarizePhases(cvm_phases)
  return(data)
}


# Smoove - Change Points

#' Find Change Points
#'
#' @param mode a character vector of length one, for the type of model. The only
#'   possible value for this model is "segmentation".
#' @param engine a character vector of length one, specifying what computational engine
#'   to use for fitting. Possible engines are listed below. The default for this
#'   model is `"smoove"`.
#' @param cp_id_col a character vector of length one, specifying the name of the
#'   column to be used for the change point identifiers. Default is "cp_id".
#' @param windowsize time window of analysis to scan, IMPORTANTLY: in units of time (T).
#' @param windowstep step (in time) by which the window advances.  The smaller the step, the slower
#' but more thorough the estimation.
#' @param time_unit of the windowsize AND the windowstep. The default is "hours" - can be any of
#' "secs", "mins", "hours", "days", "weeks" (See \code{\link[base]{difftime}}).
#' Ignored if time is not POSIX.
#' @param progress whether or not to show a progress bar
#' @param .parallel if set TRUE, will use \code{\link[foreach]{foreach}} to parallelize the
#' optimization.  Requires establishing the
#' @param model model to fit for the change point sweep - typically the most complex model in the
#' candidate model set.
#' @param clusterwidth A time span within which very close change points are considered a
#' single change point.
#' @param modelset set of models to compare (combination of UCVM, ACVM, RCVM, RACVM, or \code{all},
#' which includes all of them)
#' @param spline whether or not to use the spline approximation for the final estimate.
#' @param criterion selection criterion - either BIC or AIC (can be upper- or lowercased)
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
  cp_id_col = "cp_id",
  windowsize = 1000,
  windowstep = 50,
  model = "UCVM",
  progress = TRUE,
  time_unit = "mins",
  .parallel = FALSE,
  clusterwidth = NULL,
  modelset = "all",
  spline = TRUE,
  criterion = "BIC"
) {
  args <- list(
    cp_id_col = cp_id_col,
    windowsize = windowsize,
    windowstep = windowstep,
    model = model,
    progress = progress,
    time_unit = time_unit,
    .parallel = .parallel,
    clusterwidth = clusterwidth,
    modelset = modelset,
    spline = spline,
    criterion = criterion
  )
  new_travelpath_spec(
    "cvm_change_points",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}


#' Smoove estimate phases
#'
#' @param mode a character vector of length one, for the type of model. The only
#'   possible value for this model is "grouping".
#' @param engine a character vector of length one, specifying what computational engine
#'   to use for fitting. Possible engines are listed below. The default for this
#'   model is `"smoove"`.
#' @param criterion an information criterion such as BIC, AIC etc.
#' @param verbose whether to print a summary of the results
#' @param phase_id_col a character vector of length one, specifying the name of the
#'   column to be used for the phase identifiers. Default is "phase_id".
#'
#' @return An `infomap` specification.
#'
#' @examples
#' infomap()
#'
#' # Specify the criterion
#' cvm_phases(
#'   criterion = "BIC"
#' )
#' @rdname cvm_phases
#' @export
cvm_phases <- function(
  mode = "grouping",
  engine = "smoove",
  criterion = "BIC",
  verbose = TRUE,
  phase_id_col = "phase_id"
) {
  args <- list(
    criterion = criterion,
    verbose = verbose,
    phase_id_col = phase_id_col
  )
  new_travelpath_spec(
    "cvm_phases",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}
