
#' Travelpath Fit
#'
#' Constructor for the fit \code{"travelpath_fit"} object.
#'
#' @param spec an object of class \code{"travelpath_spec"},
#'   giving the original specification storing the options used to fit.
#' @param fit the engine output, stored as-is.
#' @param elapsed an object of class \code{"proc_time"} (as returned by
#'   \code{\link[base]{proc.time}}) giving how long the fit took.
#' @param preproc a list of preprocessing artifacts, currently a
#'   placeholder (empty list) reserved for future predict
#'   data transformations.
#' @param meta an optional list for storing additional information.
#'
#' @return an object of class
#'   \code{c("<engine>_fit", "<mode>_fit", "travelpath_fit")}, where
#'   \code{<mode>} is either \code{"segmentation"} or \code{"grouping"}
#'   taken from \code{spec[["mode"]]}.
#'
#' @export
new_travelpath_fit <- function(
  spec,
  fit,
  elapsed = NULL,
  preproc = list(),
  meta = NULL
) {
  assert_spec(spec)
  checkmate::assert_class(elapsed, "proc_time", null.ok = TRUE)
  checkmate::assert_list(preproc)
  obj <- list(
    spec = spec,
    fit = fit,
    preproc = preproc,
    elapsed = elapsed,
    meta = meta
  )
  class_addon <- sprintf("%s_fit", c(spec[["engine"]], spec[["mode"]]))
  class(obj) <- c(class_addon, "travelpath_fit")
  obj
}


#' Specification Accessor Function
#'
#' The \link{specification} of a given travelpath fit
#' (\code{"travelpath_fit"}) can be accessed via the method \code{'specification'}.
#'
#' @param x object from which the specification is extracted.
#' @param \ldots further arguments currently ignored.
#'
#' @return an object inheriting from \code{"travelpath_spec"}
#'
#' @rdname specification
#' @export
specification <- function(x, ...) {
  UseMethod("specification")
}


#' @noRd
#' @export
specification.travelpath_fit <- function(x, ...) {
  x[["spec"]]
}


#' Extract Fit
#'
#' The raw engine object of a given \code{"travelpath_fit"} can be
#' accessed via the method \code{'fitted'}. The
#' returned object is whatever the engine produced, it
#' is stored verbatim and is not mutated by \pkg{travelpaths}.
#' For the built-in engines this is typically a trackframe with
#' an extra column.
#'
#' @param object object from which the fit is extracted.
#' @param \ldots further arguments currently ignored.
#'
#' @return the raw engine object as returned by the engine.
#'
#' @export
fitted.travelpath_fit <- function(object, ...) {
  object[["fit"]]
}


#' Extract Elapsed Time
#'
#' The timing information of a given \code{"travelpath_fit"} can
#' be accessed via the method \code{'elapsed'}.
#'
#' @param x object from which the elapsed time is extracted.
#' @param \ldots further arguments currently ignored.
#'
#' @return an object of class \code{"proc_time"} as returned by
#'   \code{\link[base]{proc.time}}
#'
#' @rdname elapsed
#' @export
elapsed <- function(x, ...) {
  UseMethod("elapsed")
}


#' @noRd
#' @export
elapsed.travelpath_fit <- function(x, ...) {
  x[["elapsed"]]
}


#' Accessor Functions for Segments and Groups
#'
#' The number of segments or groups produced by a \code{"travelpath_fit"}
#' can be accessed via \code{'n_segments'} and \code{'n_groups'}.
#' These are mode-specific:
#'   use \code{n_segments()} for a \code{"segmentation"} fit,
#'   and \code{n_groups()} for a \code{"grouping"} fit.
#'
#' @param x object from which the number of groups or segments are extracted.
#' @param \ldots further arguments currently ignored.
#'
#' @return an integer vector giving the number of segments or groups for each track.
#'
#' @rdname n_segments
#' @export
n_segments <- function(x, ...) {
  UseMethod("n_segments")
}


#' @noRd
#' @export
n_segments.segmentation_fit <- function(x, ...) {
  x[["meta"]][["n_segments"]]
}


#' @rdname n_segments
#' @export
n_groups <- function(x, ...) {
  UseMethod("n_groups")
}


#' @noRd
#' @export
n_groups.grouping_fit <- function(x, ...) {
  x[["meta"]][["n_groups"]]
}


#' @export
#' @noRd
print.travelpath_fit <- function(x, n = 10, ...) {
  spec <- specification(x)
  fit <- fitted(x)
  writeLines(sprintf("<%s>: ", class(x)[1]))
  spec_str <- capture.output(str(spec))
  spec_str <- capture.output(str(spec))
  spec_str[1] <- sprintf("- spec_str: list[%i]", length(spec))
  spec_str <- spec_str[-length(spec_str)]
  spec_str <- gsub("\\s+\\$", "  -", spec_str)
  spec_str <- gsub("\\s+\\.{2}\\$", "    -", spec_str)
  spec_str <- gsub("\\s*:List.*", "", spec_str)
  writeLines(spec_str)
  if (NCOL(fit) > 1L) {
    writeLines(sprintf("- fit: %s[%i, %i]", class(fit)[1], NROW(fit), NCOL(fit)))
    if (NROW(fit) <= n) {
      writeLines(sprintf("  %s", capture.output(print(fit))))
    } else {
      nx <- floor(n / 2)
      heta <- rbind(head(fit, nx), tail(fit, n = nx))
      txt <- capture.output(print(heta))
      writeLines(sprintf("  %s", head(txt, nx + 1L)))
      writeLines("  ...")
      writeLines(sprintf("  %s", tail(txt, nx)))
    }
  } else {
    writeLines(sprintf("- fit: %s[%i]", class(fit)[1], NROW(fit)))
    str(fit)
  }
  invisible(x)
}
