

#' Assert that a travelpath spec is valid
#'
#' @param spec an travelpath spec object.
#' @return R `NULL` if valid, throws an error otherwise.
#' @export
assert_spec <- function(spec) {
  UseMethod("assert_spec")
}


#' @noRd
#' @export
assert_spec.travelpath_spec <- function(spec) {
  checkmate::assert_string(class(spec)[1])
  checkmate::assert_string(spec[["mode"]])
  checkmate::assert_string(spec[["engine"]])
}
