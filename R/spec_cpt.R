# Change Point Test


#' Change Point Permutation Test Specification
#'
#' Constructs a travelpath specification for change point detection using a
#'   permutation test. This function creates a specification object for change
#'   point analysis using the `cpt::change_point_test` engine. The method
#'   detects change points in a sequence by comparing segments using a specified
#'   distance metric and assessing significance
#' via permutation testing.
#'
#' @param mode The analysis mode. Only "segmentation" is supported.
#' @param engine The computational engine to use. Default is "cpt".
#' @param alpha Significance level for the permutation test (default: 0.05).
#' @param output_col Name of the output column added to the trackframe
#'   (default: \code{"cp_id"}).
#'
#' @return A travelpath specification object for change point detection.
#'
#' @details
#' This specification uses the `cpt::change_point_test` function to perform
#' change point detection via permutation testing.
#'
#' @seealso [cpt::change_point_test()]
#'
#' @examples
#' spec <- change_point_permtest(alpha = 0.01)
#'
#' @export
change_point_permtest <- function(
  mode = "segmentation",
  engine = "cpt",
  alpha = 0.05,
  output_col = "cp_id"
) {
  args <- list(
    alpha = alpha,
    output_col = output_col
  )
  new_travelpath_spec(
    "change_point_permtest",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}
