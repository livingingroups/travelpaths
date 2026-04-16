library("checkmate")
library("infostop")

data(package = "trackframe")
data("path_trackframe", package = "trackframe")
data("path_move2", package = "trackframe")


files <- dir("R", pattern = ".R$", full.names = TRUE)
for (file in files) {
  source(file)
}


object <- threshold_stops(
  distance_metric = "haversine",
  r1 = 20,
  min_size = 3
)


assert_spec <- function(spec) {
  UseMethod("assert_spec")
}


assert_spec.travelpath_spec <- function(spec) {
  assert_string(class(spec)[1])
  assert_string(spec[["mode"]])
  assert_string(spec[["engine"]])
}


spec <- object
data <- path_move2

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
      "%s '%s' with mode '%s' and engine '%s'.\n%s\nℹ Run `show_engines('%s')` %s",
      "No fitting method found for model",
      model_name,
      object[["mode"]],
      object[["engine"]],
      "✖ Please check that the engine is correctly specified and supported.",
      model_name,
      "to see available engines for this model."
    )
    stop(msg)
  }
  do.call(fit_function, c(list(data), spec[["args"]], spec[["eng_args"]]))
}


res <- fit(spec, path_move2)
head(res)



#
# Examples
#
library("travelpaths")

ths_spec <- threshold_stops(
  r1 = 20,
  min_size = 3
)

stops <- fit(ths_spec, path_move2)
head(stops)
colnames(stops)
colnames(path_move2)


im_spec <- infomap()
sites <- fit(im_spec, stops)
head(sites)


group_locations <- function(data, clu_col, fun = median) {
  UseMethod("group_locations", data)
}


group_locations.move2 <- function(data, clu_col, fun = median) {

}





#
# Parsnip
#
library("parsnip")
library("tidymodels")
show_engines("linear_reg")
show_model_info("linear_reg")

grep("show", ls(getNamespace("parsnip")), value = TRUE)


#
#
#
files <- dir("R", pattern = ".R$", full.names = TRUE)
for (file in files) {
  tools::showNonASCIIfile(file)
}

