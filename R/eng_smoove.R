# Find Candidate Change Points
#
# A slightly modified version of smoove::findCandidateChangePoints.
# Also stores the minimum clusterwidth in the attributes of the output.
#
# @details The raw output of the window sweep from \code{\link{sweepRACVM}}.
#
# @param windowsweep A windowsweep object (matrix), output of \code{\link{sweepRACVM}}.
# @param clusterwidth A time span within which very close change points are considered
#   a single change point.
# @param verbose Whether to report the number of change points that are clustered away.
#
# @examples
# library(smoove)
# library(travelpaths)
# data(simSweep, package = "smoove")
# cp_all <- travelpaths:::find_candidate_change_points(windowsweep = simSweep, clusterwidth = 0)
# as.vector(cp_all)
# cp_cl <- travelpaths:::find_candidate_change_points(windowsweep = simSweep, clusterwidth = 4)
# as.vector(cp_cl)
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

  # compute number of points per segment
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


# The candidate_cps can lie outside of the domain of the data.
# This function finds the first change point inside the domain,
# therefore the first point within the data that is bigger or equal
# the change point candidate.
# We use this since floor, ceil approaches only work where e.g.
# for every second there is a data point available.
first_match <- function(x, table) {
  splitted <- split(x, cut(x, c(table, max(x)), include.lowest = TRUE))
  new <- unlist(lapply(splitted, head, 1L), FALSE, FALSE)
  attributes(new) <- attributes(table)
  new
}


# @param data currently a trackframe
# @param ... ...
# @rdname cvm_change_points
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
  checkmate::assert_class(data, classes = "trackframe")
  checkmate::assert_numeric(clusterwidth, null.ok = TRUE, lower = 0)
  assert_unique_timestamps(data)

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
  list(
    data = data,
    cp_id_col = cp_id_col,
    cp_table = cp_table
  )
}


# @param data currently a trackframe
# @export
# @rdname cvm_phases
cvm_estimate_phases <- function(
  data,
  cp_table,
  criterion = "BIC",
  verbose = TRUE,
  phase_id_col = "phase_id"
) {
  checkmate::assert_class(data, classes = "trackframe")

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
    as.integer(names(idx_phases)),
    times = lengths(idx_phases)
  )

  summary_phases <- smoove::summarizePhases(cvm_phases)
  colnames(summary_phases) <- swap(colnames(summary_phases), "phase" = phase_id_col)
  summary_phases[[phase_id_col]] <- as.integer(summary_phases[[phase_id_col]])
  attr(data, "cvm_phases") <- cvm_phases
  attr(data, "summary_phases") <- summary_phases
  data
}


cvm_segment <- function(
  data,
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
  output_col = "phase_id",
  ...
) {
  fit_cpt <- cvm_estimate_change_points(
    data,
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
    ...
  )
  fitted <- cvm_estimate_phases(
    fit_cpt[["data"]],
    fit_cpt[["cp_table"]],
    criterion = criterion,
    verbose = verbose,
    phase_id_col = output_col
  )
  list(
    fit = fitted,
    fit_class = "smoove_fit",
    preproc = list(),
    meta = .cvm_segment_meta(fitted, output_col)
  )
}


.cvm_segment_meta <- function(fitted, phase_id_col) {
  meta <- list(
    n_segments = length(na.omit(unique(fitted[[phase_id_col]])))
  )
  meta[[phase_id_col]] <- attr(fitted, "summary_phases")
  meta
}
