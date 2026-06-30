
#' Accessor Functions to Obtain Segment / Group Column
#'
#' The name of the column in the fit where the newly created
#' segmentation or grouping is stored.
#'
#' @param x the object from which the column name should be extracted.
#' @param \ldots additional arguments currently ignored.
#'
#' @return a character vector giving the name of the column where the
#'   output is stored.
#'
#' @rdname segment_col
#' @export
segment_col <- function(x, ...) {
  UseMethod("segment_col")
}


#' @noRd
#' @export
segment_col.travelpath_spec <- function(x, ...) {
  x[["args"]][["output_col"]]
}


#' @noRd
#' @export
segment_col.segmentation_fit <- function(x, ...) {
  segment_col(x[["spec"]], ...)
}


#' @rdname segment_col
#' @export
group_col <- function(x, ...) {
  UseMethod("group_col")
}


#' @noRd
#' @export
group_col.travelpath_spec <- function(x, ...) {
  x[["args"]][["output_col"]]
}


#' @noRd
#' @export
group_col.grouping_fit <- function(x, ...) {
  group_col(x[["spec"]], ...)
}


#' Metadata from a segmentation / grouping fit
#'
#' `segment_meta()` and `group_meta()` return the `meta` slot
#' (a \code{data.frame} with one row per segment / group, or `NULL`)
#' with the mode-specific dispatch used by the rest of the package.
#'
#' @param x a \code{travelpath_fit} object.
#' @param ... additional arguments currently unused.
#'
#' @return A `data.frame` with `n_groups(x)` rows, or `NULL` when
#'   the engine provides no per-label metadata.
#'
#' @export
segment_meta <- function(x, ...) {
  UseMethod("segment_meta")
}


#' @rdname segment_meta
#' @export
group_meta <- function(x, ...) {
  UseMethod("group_meta")
}


#' @noRd
#' @export
segment_meta.segmentation_fit <- function(x, ...) {
  x[["meta"]][[segment_col(x)]]
}


#' @noRd
#' @export
group_meta.grouping_fit <- function(x, ...) {
  x[["meta"]][[group_col(x)]]
}


#' Augment a Trackframe with the Fit Output
#'
#' \code{augment()} writes the fit's assignment column onto
#'   \code{new_data}. \code{new_data} is expected to be the
#'   training trackframe (same rows in the same order as the
#'   data originally passed to \code{\link{fit.travelpath_spec}}).
#'
#' @param x an object of class \code{"travelpath_fit"}.
#' @param new_data a trackframe, normally the same data used for training.
#' @param output_col a character scalar giving the column name to write.
#'   If \code{NULL} (the default), the name is taken from
#'   \code{\link{segment_col}(x)} or \code{\link{group_col}(x)}.
#' @param \ldots additional arguments currently unused.
#'
#' @return \code{new_data} augmented with the fit result.
#'
#' @name augment.travelpath_fit
NULL


#' @noRd
#' @export
augment.segmentation_fit <- function(x, new_data, output_col = NULL, ...) {
  seg_id_col <- segment_col(x)
  output_col <- output_col %||% seg_id_col
  fitted <- x[["fit"]]
  stopifnot(all(fitted[, tf_colnames(fitted)] == new_data[, tf_colnames(new_data)]))
  new_data[[output_col]] <- fitted[[seg_id_col]]
  new_data
}


#' @noRd
#' @export
augment.grouping_fit <- function(x, new_data, output_col = NULL, ...) {
  grp_id_col <- group_col(x)
  output_col <- output_col %||% grp_id_col
  fitted <- x[["fit"]]
  stopifnot(all(fitted[, tf_colnames(fitted)] == new_data[, tf_colnames(new_data)]))
  new_data[[output_col]] <- fitted[[grp_id_col]]
  new_data
}
