
#' Validate Function Arguments
#'
#' This function is used to verify that the arguments provided via
#' `object[["args"]]` and `object[["eng_args"]]` actually match
#' the signature of the function.
#' First it checks that all required arugments are provided.
#' Second it checks (if the function has no varargs) that no arguments
#' are provided that are not present in the function signature.
#'
#' @param fun a function to validate arguments against.
#' @param fun_args a list of arguments (positional and/or named) to validate.
#' @return `NULL` invisibly; stops with an error if arguments are invalid.
#' @keywords internal
#' @noRd
validate_function_arguments <- function(fun, fun_args) {
  all_args <- formals(fun)
  arg_names <- names(all_args)
  has_varargs <- "..." %in% arg_names
  has_default <- !as.logical(lapply(all_args, is.symbol))
  required_args <- setdiff(arg_names[!has_default], "...")

  if (is.null(names(fun_args))) {
    names(fun_args) <- rep("", length(fun_args))
  }
  args <- fun_args[names(fun_args) == ""]
  kwargs <- fun_args[names(fun_args) != ""]

  required_args <- required_args[!required_args %in% names(kwargs)]

  if (length(args) < length(required_args)) {
    missing_args <- required_args[seq(length(args) + 1, length(required_args))]
    missing_args <- paste(shQuote(missing_args), collapse = ", ")
    stop(sprintf("arguments %s are missing, with no default.", missing_args))
  } else if (length(args) > length(arg_names) && !has_varargs) {
    emsg <- paste(
      "too many arguments provided.",
      sprintf("Expected at most %d, got %d.", length(all_args), length(args))
    )
    stop(emsg)
  }
  if (!has_varargs) {
    extra_kwargs <- setdiff(names(kwargs), arg_names)
    if (length(extra_kwargs) > 0) {
      extra_kwargs <- paste(shQuote(extra_kwargs), collapse = ", ")
      stop(sprintf("unexpected keyword arguments: %s.", extra_kwargs))
    }
  }
}


map_arguments <- function(object, fit_args) {
  mapping <- get_argument_mapping(object)
  if (length(mapping) == 0) {
    return(fit_args)
  }
  m <- match(names(fit_args), names(mapping))
  idx <- which(!is.na(m))
  names(fit_args)[idx] <- mapping[m[idx]]
  fit_args
}


#' Fit a Travelpath Model Specification
#'
#' @description
#'
#' `fit.travelpath_spec()` is the S3 method for fitting travelpath model
#' specifications to movement data. This function takes a travelpath
#' specification object and applies the specified algorithm to the provided
#' data using the configured engine and parameters.
#'
#' @param object A travelpath specification object created by functions like
#'   `threshold_stops()` or `infomap()`. The object contains the model type,
#'   mode, engine, and parameter settings.
#' @param data A movement data object (e.g., trackframe, move2, sftrack)
#'   containing the trajectory data to be analyzed.
#' @param ... Additional arguments passed to the underlying fitting function.
#'
#' @details
#'
#' This function serves as the main interface for fitting travelpath models.
#' It performs the following steps:
#'
#' 1. Validates the specification object
#' 2. Determines the appropriate fitting function based on the model, mode, and engine
#' 3. Calls the fitting function with the data and specification parameters
#'
#' The fitting function is retrieved using the model registry system, which
#' maps combinations of model types, modes, and engines to their corresponding
#' implementation functions.
#'
#' @return The return value depends on the specific model and engine used:
#' - For stop detection models: Returns the input data with added stop identifiers
#' - For site identification models: Returns the input data with added site identifiers
#' - For changepoint models: Returns segmentation information
#'
#' @examples
#' \dontrun{
#' # Fit a threshold stops model
#' stops_spec <- threshold_stops(r1 = 20, min_size = 3)
#' result <- fit(stops_spec, movement_data)
#'
#' # Fit an infomap sites model
#' sites_spec <- infomap(r2 = 50, weighted = TRUE)
#' result <- fit(sites_spec, stops_data)
#' }
#'
#' @seealso [threshold_stops()], [infomap()], [register_fit_function()]
#' @export
fit.travelpath_spec <- function(
  object,
  data,
  ...
) {
  assert_spec(object)
  model_name <- class(object)[1]
  fit_function <- get_fit_function(object)
  if (is.null(fit_function)) {
    msg <- sprintf(
      "%s '%s' with mode '%s' and engine '%s'.\n%s\n\u2139 Run `show_engines('%s')` %s",
      "No fitting method registered for model",
      model_name,
      object[["mode"]],
      object[["engine"]],
      "\u2716 Please check that the engine is correctly specified and supported.",
      model_name,
      "to see available engines for this model."
    )
    stop(msg)
  }
  # NOTE: We don't do strict checks on data here, we expect the function fit
  #       dispatches to, to do the input validation.
  checkmate::assert_true(!is.null(data))

  control <- list(...)
  dry_run <- isTRUE(control$dry_run)
  if (!is.null(control$dry_run)) {
    control$dry_run <- NULL
  }

  fit_args <- c(list(data), object[["args"]], object[["eng_args"]])
  fit_args <- map_arguments(object, fit_args)

  if (!is.null(control)) {
    fit_args <- update_list(fit_args, control)
  }

  validate_function_arguments(fit_function, fit_args)

  rcall <- c(list(fit_function), fit_args)
  # This is very useful for debugging. It allows developers exactly to see how the
  # fit function is called, without actually running it.
  if (dry_run) {
    return(rcall)
  }
  mode(rcall) <- "call"
  result <- eval(rcall)
  class_addon <- sprintf("%s_fit", object[["mode"]])
  class(result) <- c(class_addon, class(result))
  result
}


#
# FIXME: This would be more similar to tidymodels style.
#
# mode(rcall) <- "call"
# result <- list(
#   spec = object
# )
# start_time <- proc.time()
# result[["fit"]] <- eval(rcall)
# result[["elapsed"]] <- proc.time() - start_time
# model_class <- sprintf("%s_fit", object[["mode"]])
# class(result) <- c(sprintf("_%s", class(result[["fit"]])), model_class)
# result
