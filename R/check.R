
assert_spec <- function(spec, null.ok = FALSE) {  # nolint: object_name_linter
  if (is.null(spec) && null.ok) {
    return(spec)
  }
  checkmate::assert_class(spec, "travelpath_spec")
  checkmate::assert_string(spec[["mode"]])
  checkmate::assert_string(spec[["engine"]])
  return(spec)
}


assert_unique_timestamps <- function(object, time_unit = NULL) {
  checkmate::assert_class(object, "trackframe")
  if (is.null(time_unit)) {
    timestamp <- time(object)
  } else {
    timestamp <- lubridate::ceiling_date(time(object), unit = time_unit)
  }
  tf <- data.frame(id = id(object), ts = timestamp)
  checkmate::assert(anyDuplicated(tf) == 0L)
  return(object)
}
