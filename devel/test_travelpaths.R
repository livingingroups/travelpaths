library("trackframe")
library("infostop")
library("cpt")
library("smoove")
library("travelpaths")
library("generics")

data(package = "trackframe")
data(package = "cpt")
data("path_move2", package = "trackframe")
data("paths_trackframe", package = "trackframe")
data("cpttestdata")


#
#
#
spec <- threshold_stops()
x <- arguments(spec)

?str
str(as.list(x))
utils:::str.default


#
# infostop
#
ths_spec <- threshold_stops(
  distance_metric = "haversine",
  r1 = 20,
  min_size = 3
)

stops <- fit(ths_spec, path_move2)
head(stops)

im_spec <- infomap()
sites <- fit(im_spec, stops)
head(sites)


#
# cpt
#
data("cpttestdata", package = "cpt")
cpt_spec <- change_point_permtest(alpha = 0.05)

rcall <- fit(cpt_spec, cpttestdata, dry_run = TRUE)
str(rcall)

cpt_tf <- fit(cpt_spec, cpttestdata)
head(cpt_tf)



head(cpttestdata)
cpt_tf <- change_point_test(cpttestdata, alpha = 0.05, q = 3, n = 500, min_move_dist = 0)
cpt_tf


cppt_spec <- change_point_permtest(alpha = 0.05)
cppt_spec$eng_args <- list(q = 3, n = 500, min_move_dist = 0)
str(cppt_spec)

rcall <- fit(cppt_spec, cpttestdata, dry_run = TRUE)
str(rcall)

cp <- fit(cppt_spec, cpttestdata)
cp

data <- cpttestdata


arguments <- function(x, ...) {
  UseMethod("arguments")
}


arguments.travelpath_spec <- function(x, ...) {
  model_name <- class(x)[1]
  fit_function <- travelpaths:::get_fit_function(x)
  formals(fit_function)  
}


args(fun)
formals(fun)


allargs <- formals(fit_function)  
names(allargs)
str(allargs)

has_default <- !as.logical(lapply(allargs, is.symbol))
has_varargs <- names(allargs) == "..."
arg_names <- setdiff(names(allargs)[!has_default], "...")
kwarg_names <- names(allargs)[has_default]



kwargs <- c(object[["args"]], object[["eng_args"]])
str(kwargs)

fun_args <- c(list(data), object[["args"]], object[["eng_args"]])
fun_args <- c(list(data), list(), list())
fun_args <- list()
names(fun_args)
str(fun_args)

fun <- function(a, b, c = 3, d = 4, ...) c(a, b, c, d)
fun(1)


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


fun_1 <- function(a, b, c = 3, d = 4, ...) c(a, b, c, d)
validate_function_arguments(fun_1, list(1, 2))  # OK
validate_function_arguments(fun_1, list(1, c = 2))  # Error: missing "b"
validate_function_arguments(fun_1, list(d = 1, c = 2))  # Error: missing "a", "b"
validate_function_arguments(fun_1, list(1, 2, 3, 4, 5))  # OK: 5 goes into ...

fun_2 <- function(a, b, c = 3, d = 4) c(a, b, c, d)
validate_function_arguments(fun_2, list(1, 2))  # OK
validate_function_arguments(fun_2, list(1, c = 2))  # Error: missing "b"
validate_function_arguments(fun_2, list(d = 1, c = 2))  # Error: missing "a", "b"
validate_function_arguments(fun_2, list(1, 2, 3, 4, 5))  # Error: too many arguments
validate_function_arguments(fun_2, list(1, 2, z = 9))


fun <- fun_1
fun_args <- list(1, c = 2)


head(as.list(args(fit_function)), -1L)
pairlist


arguments(threshold_stops())


get_fit_function

getNamespace(x[["engine"]])

object <- x <- cppt_spec
str(cppt_spec)



# library("smoove")


# new_segmentaion_model <- function() {

# }


# out <- list(
#   args = args,
#   eng_args = eng_args,
#   mode = mode,
#   user_specified_mode = user_specified_mode,
#   method = method,
#   engine = engine,
#   user_specified_engine = user_specified_engine
# )




foo <- function(a, b, c, d = 4, e = 5) {
  c(a, b, c, d, e)
}


foo(1, 2, 3, e = 6)

foo(e = 6, 1, d = 4, 2, 3)



