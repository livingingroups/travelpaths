#
# We want to be consistent to tidymodels and tidyclust without adding all the dependencies.
# Therefore, we follow a similar approach with regards to the model specification.
# - new_model_spec: https://github.com/tidymodels/parsnip/blob/main/R/misc.R
# - new_cluster_spec: https://github.com/tidymodels/tidyclust/blob/main/R/cluster_spec.R
#

#
# - mode: "unknown", "regression", "classification", "partition"
# - engine: "hdbscan", "kmeans", "clara", "fanny", "pam", "som", "hierarchical"
#
# - mode: "segmentation", "grouping"

#' Constructor for travelpath specification objects
#'
#' `new_travelpath_spec()` is a developer-oriented constructor function for
#' creating new travelpath specification objects. This function is used
#' internally by user-facing specification functions.
#'
#' @param cls a character string for the class of the specification (e.g.,
#'   "stop_detection").
#' @param args a list of main arguments for the specification.
#' @param eng_args a list of engine-specific arguments, typically an empty
#'   `list()` or `NULL` when creating a new specification.
#' @param mode a character string for the type of travel path analysis.
#'   Possible values are "segmentation" or "grouping" or "unknown".
#' @param engine a character string for the computational engine.
#'
#' @return A travelpath specification object with class `cls`.
#'
#' @export
new_travelpath_spec <- function(cls, args, eng_args, mode, engine) {
  checkmate::assert_string(cls, min.chars = 1)
  checkmate::assert_list(args)
  checkmate::assert_list(eng_args)
  checkmate::assert_string(mode, min.chars = 1)
  checkmate::assert_string(engine, min.chars = 1)
  obj <- list(
    args = args,
    eng_args = eng_args,
    mode = mode,
    # I decided to fix it to NULL rather than always passing `NULL` and having to document
    # an argument that is never used.
    method = NULL,
    engine = engine
  )
  class(obj) <- c(cls, "travelpath_spec")
  obj
}


# We should automatically select which params are relevant.
.update_args <- function(object, params = list(), fresh = FALSE) {
  if (fresh) {
    args <- get(class(object)[1])()[["args"]]
  } else {
    args <- object[["args"]]
  }
  keys <- intersect(names(args), names(params))
  args[keys] <- params[keys]
  object[["args"]] <- args
  object
}


.update_eng_args <- function(object, params = list(), fresh = FALSE) {
  args <- get(class(object)[1])()[["args"]]
  all_args <- arguments(object)
  has_default <- !as.logical(lapply(all_args, is.symbol))
  eng_args_names <- setdiff(names(all_args)[has_default], names(args))
  if (fresh) {
    eng_args <- list()
  } else {
    eng_args <- object[["eng_args"]]
  }
  keys <- intersect(eng_args_names, names(params))
  eng_args[keys] <- params[keys]
  object[["eng_args"]] <- eng_args
  object
}


.update_spec <- function(object, params = list(), fresh = FALSE, ...) {
  params <- update_list(params, list(...), method = "union")
  object <- .update_args(object, params, fresh)
  object <- .update_eng_args(object, params, fresh)
  object
}


#' Update a travelpath specification object
#'
#' Update the parameters of a travelpath specification object with new values.
#' This function allows you to modify the arguments and engine-specific
#' arguments of an existing travelpath specification.
#'
#' @param object A travelpath specification object to be updated.
#' @param params A named list of parameters to update. The function will
#'   automatically determine which parameters are main arguments vs
#'   engine-specific arguments based on the specification's formal arguments.
#' @param fresh A logical value indicating whether to start with fresh default
#'   values (`TRUE`) or preserve existing parameter values (`FALSE`, default).
#'   When `TRUE`, only the parameters specified in `params` will be set, all
#'   others will revert to defaults.
#' @param ... Additional named parameters to update. These will be combined with
#'   the `params` list.
#'
#' @return An updated travelpath specification object with the same class as the
#'   input object.
#'
#' @examples
#' spec <- threshold_stops(min_staying_time = 5)
#' updated_spec <- update(spec, params = list(min_staying_time = 10))
#' fresh_spec <- update(spec, fresh = TRUE, min_staying_time = 15)
#' @export
update.travelpath_spec <- function(object, params = list(), fresh = FALSE, ...) {
  .update_spec(object, params, fresh, ...)
}


#' Extract arguments from an object
#'
#' This method extracts the formal arguments of an object.
#' For objects of `travelpath_spec` extracts the formal arguments of the
#' fitting function associated with a travelpath specification object.
#'
#' @param x an object.
#' @param ... additional arguments (currently unused).
#'
#' @return A pairlist of formal arguments from the associated function,
#'   as returned by `formals()`.
#'
#' @examples
#' spec <- threshold_stops()
#' arguments(spec)
#' @export
arguments <- function(x, ...) {
  UseMethod("arguments")
}


#' @noRd
#' @export
arguments.travelpath_spec <- function(x, ...) {
  fit_function <- get_fit_function(x)
  res <- formals(fit_function)
  class(res) <- unique(c("function_arguments", class(res)))
  res
}


#' @noRd
#' @export
print.function_arguments <- function(x, ...) {
  repr <- capture.output(str(unclass(x)))
  header <- sprintf("Function with %i arguments:", length(repr) - 1)
  writeLines(c(header, repr[-1]))
}
