library("travelpaths")

spec <- change_point_permtest()
arguments(spec)
object <- spec

get_args <- function(object) {
  
}


model <- class(object)[1]
mode <- object[["mode"]]
engine <- object[["engine"]]
register_argument_mapping(model, mode, engine, c("n_permutations" = "n_perm"))


fit_function <- travelpaths:::get_fit_function(object)
all_args <- formals(fit_function)
has_default <- !as.logical(lapply(all_args, is.symbol))
args <- object[["args"]]

mapping <- travelpaths:::get_argument_mapping(object)

eng_args <- object[["eng_args"]]
eng_args


