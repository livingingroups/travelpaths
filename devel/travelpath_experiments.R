
# @noRd
# @export
infostop_spec <- function(
  r1 = 10,
  r2 = 10,
  label_singleton = TRUE,
  min_staying_time = 300L,
  max_time_between = 86400L,
  min_size = 2L,
  min_spacial_resolution = 0,
  distance_metric = "euclidean",
  weighted = FALSE,
  weight_exponent = 1,
  verbose = FALSE,
  ...
) {
  args <- c(as.list(environment()), list(...))
  obj <- list(
    args = args
  )
  class(obj) <- c("infostop_spec", "segmentation_spec")
  obj
}


# @noRd
# @export
change_point_test_model <- function(
  alpha = 0.05,
  q = 4,
  N = 1000,
  tol = 0,
  clu = NULL,
  seed = NULL,
  ...
) {
  args <- c(as.list(environment()), list(...))
  obj <- list(
    args = args
  )
  class(obj) <- c("cpt_spec", "segmentation_spec")
  obj
}


# @noRd
# @export
correlated_velocity_movement_model <- function(
  windowsize,
  windowstep,
  model = "UCVM",
  progress = TRUE, 
  time.unit = "hours",
  p0 = NULL,
  spline = FALSE,
  spline.res = 0.01,
  T.spline = NULL,
  time.units = "days",
  verbose = FALSE,
  ...,
  .parallel = FALSE
) {
  args <- c(as.list(environment()), list(...))
  obj <- list(
    args = args
  )
  class(obj) <- c("cvm_spec", "segmentation_spec")
  obj
}


# @noRd
# @export
fit.infostop_spec <- function(object, data, ...) {
  obj <- list(spec = object)
  obj$fit <- do.call(infostop::find_stops, c(list(data = data), object$args))
  class(obj) <- c("infostop_fit", "segmentation_fit")
  obj
}


# @noRd
# @export
fit.cpt_spec <- function(object, data, ...) {
  obj <- list(spec = object)
  obj$fit <- do.call(cpt::cpt, c(list(data = data), object$args))
  class(obj) <- c("cpt_fit", "segmentation_fit")
  obj
}


# @noRd
# @export
fit.cvm_spec <- function(object, data, ...) {
  obj <- list(spec = object)
  obj$fit <- do.call(sweep_racvm, c(list(data = data), object$args))
  class(obj) <- c("cvm_fit", "segmentation_fit")
  obj
}


# @noRd
# @export
tp_segment <- function(model, data, ...) {
  tp_segment(model, data, ...)
}


# @noRd
# @export
tp_group <- function(model, data, ...) {
  UseMethod("tp_group", model)
}


# @noRd
# @export
# tp_group.infostop_fit <- function(model, data, ...) {
#   # For infostop we would not need the data argument the question is if for
#   # other methods we would need it.
#   stops <- model$fit
#   clusters <- do.call(spatial_infomap, c(list(data = stops$stop_events), model$spec$args))
#   labels <- match_labels(clusters, stops$event_map)
#   labels
# }



# change_point_test.trackframe <- function(data,
#                                           alpha = 0.05,
#                                           q = 4,
#                                           N = 1000,
#                                           tol = 0,
#                                           clu = NULL,
#                                           seed = NULL,
#                                           ...) {

# infostop.trackframe <- function(data,
#                                 r1 = 10,
#                                 r2 = 10,
#                                 label_singleton = TRUE,
#                                 min_staying_time = 300L,
#                                 max_time_between = 86400L,
#                                 min_size = 2L,
#                                 min_spacial_resolution = 0,
#                                 distance_metric = "euclidean",
#                                 weighted = FALSE,
#                                 weight_exponent = 1,
#                                 verbose = FALSE,
#                                 ...) {
# ##
#

