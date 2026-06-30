fit_db <- new.env(parent = emptyenv())
mapping_db <- new.env(parent = emptyenv())
meta_db <- new.env(parent = emptyenv())
meta_db[["fit_functions"]] <- data.frame(
  model = character(),
  mode = character(),
  engine = character(),
  stringsAsFactors = FALSE
)
meta_db[["argument_mappings"]] <- data.frame(
  model = character(),
  mode = character(),
  engine = character(),
  stringsAsFactors = FALSE
)



method_id <- function(model, mode, engine) {
  checkmate::assert_string(model)
  checkmate::assert_string(mode)
  checkmate::assert_string(engine)
  paste(c(model, mode, engine), collapse = ".")
}


#' Register a new fit function
#'
#' @param model a character string giving the model name, e.g.,
#'   `"threshold_stops"`.
#' @param mode a character string giving the mode, currently `"segmentation"`
#'   and `"grouping"` are supported.
#' @param engine a character string giving the engine, e.g., `"smoove"`.
#' @param fit_function a function to be used for fitting.
#'
#' @return Invisible `NULL`.
#'
#' @examples
#' \dontrun{
#' register_fit_function("threshold_stops", "segmentation", "infostop",
#'   infostop::identify_stops)
#' }
#'
#' @export
register_fit_function <- function(model, mode, engine, fit_function) {
  checkmate::assert_string(model)
  checkmate::assert_string(mode)
  checkmate::assert_string(engine)
  checkmate::assert_function(fit_function)
  row <- data.frame(
    model = model,
    mode = mode,
    engine = engine,
    stringsAsFactors = FALSE
  )
  meta_db[["fit_functions"]] <- unique(rbind(meta_db[["fit_functions"]], row))
  id <- method_id(model, mode, engine)
  fit_db[[id]] <- fit_function
  invisible(NULL)
}


registered_fit_functions <- function() {
  meta_db[["fit_functions"]]
}


# Get the fit function for a model specification
#
# @param object an object inheriting from class `travelpath_spec`.
#
# @return The fit function associated with the model specification.
#
# @noRd
get_fit_function <- function(object) {
  assert_spec(object)
  id <- method_id(model = class(object)[1], mode = object[["mode"]], engine = object[["engine"]])
  fit_db[[id]]
}


#' Register an argument mapping for a model specification
#'
#' @param model a character string giving the model name, e.g., `"threshold_stops"`.
#' @param mode a character string giving the mode (currently `"segmentation"`
#'   and `"grouping"` are supported).
#' @param engine a character string giving the engine, e.g., `"smoove"`.
#' @param argument_mapping a named character vector mapping the names used in
#'   `object[["args"]]` to the actual argument names expected by the fit
#'   function. The format is `c("old_name_1" = "new_name_1",
#'   "old_name_2" = "new_name_2", ...)`.
#'
#' @return Invisible `NULL`.
#'
#' @export
register_argument_mapping <- function(model, mode, engine, argument_mapping) {
  checkmate::assert_string(model)
  checkmate::assert_string(mode)
  checkmate::assert_string(engine)
  checkmate::assert_character(argument_mapping, any.missing = FALSE, names = "unique")
  id <- method_id(model, mode, engine)
  mapping_db[[id]] <- argument_mapping
  invisible(NULL)
}


get_argument_mapping <- function(object) {
  assert_spec(object)
  id <- method_id(model = class(object)[1], mode = object[["mode"]], engine = object[["engine"]])
  mapping <- mapping_db[[id]]
  if (is.null(mapping)) {
    character(0)
  } else {
    mapping
  }
}
