# working example of segmentation and grouping steps

devtools::load_all('pkgs/trackframe')
devtools::load_all('pkgs/infostop')

# has not much to do with excel
# just convert a number to base 26 letter labeling
# so that segmentation label and grouping label can have different schemes
to_grouping_label <- gcplyr::to_excel
from_grouping_label <- gcplyr::from_excel

# in trackframe package ---
# base of travelpaths package ----

# core user facing portion
travel_path_segment <- function(data, model_spec, ...) {
  # check inputs on their own
  checkmate::assert_class(data, 'track_frame') # this should be replaced with coercion
  
  # check inputs against each other
  if(requires_equidistent_times(model_spec)) {
    # check that timestamps are equidistant
    stopifnot(length(unique(diff(sort(unique(index(data)))))) == 1)
  }
  

  fit(model_spec, data)
}
travel_path_grouping <- function(segmentation_fit, model_spec, ...) {
  # check inputs on their own

  # check inputs against each other
  if(requires_segment_coords(model_spec)) checkmate::assert_class(attr(segmentation_fit, 'label_meta'), 'track_frame')


  fit(model_spec, segmentation_fit)
}

# method definitions
fit <- function(data, ...) {
  UseMethod('fit')
}

# methods that give a model's data requirements
# these are methods instead of attributes because
# they may depend on the parameters of the model spec
requires_equidistent_times <- function(model_spec) {
  checkmate::assert_class(model_spec, 'travel_path_segment_model_spec')
  UseMethod('requires_equidistent_times')
}

requires_segment_coords <- function(model_spec) {
  checkmate::assert_class(model_spec, 'travel_path_grouping_model_spec')
  UseMethod('requires_segment_coords')
}


# stop_threshold model definition ----

# constructor
new_stop_threshold_model_spec <- function(...) {
  structure(
    list(params = list(...)),
    class = c('stop_threshold_model_spec', 'travel_path_segment_model_spec', 'travel_path_model_spec', 'list')
  )
}

# user facing helper
stop_threshold_model_spec <- function(
  r1 = 10, min_staying_time = 12*60, max_time_between = 60*60 # probably more params here
) {
  # checkmate::
  # checkmate::
  new_stop_threshold_model_spec(r1, min_staying_time, max_time_between)
}

# fit method
fit.stop_threshold_model_spec <- function(model_spec, data) {
  if(!is_infostop_initialized()) infostop_initialize()
  data_mat <- matrix(
    c(
      longitude(data),
      latitude(data),
      index(data)
    ),
    c(nrow(data), 3)
  )
  raw_result <- do.call(infostop::find_stops, c(model_spec$params, list(data=data_mat, distance='euclidean')))

  # convert from 0-indexed to 1-indexed labels
  labels <- raw_result$labels + 1
  # no label = NA
  labels[which(labels == 0)] <- NA

  # data frame where each row corresponds to one segment
  # in this case it is a track frame, each segment has a connonical location
  # however that might not be applicable
  label_meta <- as.data.frame(raw_result$coordinates)
  colnames(label_meta) <- c('easting', 'northing')

  # use start of the segment as timestamp
  label_meta$index <- index(data)[match(seq_len(dim(raw_result$coordinates)[1]), labels)]

  attributes(labels) <- list(label_meta = as.track_frame(
    label_meta,
    'index',
    'easting',
    'northing'
  ), model_spec = model_spec, raw_fit = raw_result)
  class(labels) <- c('stop_threshold_fit', 'travel_path_segment_fit', 'travel_path_fit', class(labels))
  return(labels)
}

requires_equidistent_times.stop_threshold_model_spec <- function(...) FALSE

# info_map model definition ---
# constructor
new_info_map_model_spec <- function(r2) {
  structure(
    list(params = list(r2 = r2)),
    class = c('info_map_model_spec', 'travel_path_grouping_model_spec', 'travel_path_model_spec', 'list')
  )
}

# user facing helper
info_map_model_spec <- function(r2) {
  checkmate::assert_numeric(r2)
  new_info_map_model_spec(r2)
}

# fit method
fit.info_map_model_spec <- function(model_spec, segmentation_fit) {
  if(!is_infostop_initialized()) infostop_initialize()
  checkmate::assert_false(is.null(attr(segmentation_fit, 'label_meta')))
  segment_coords <- attr(segmentation_fit, 'label_meta')
  data_mat <- matrix(
    c(
      longitude(segment_coords),
      latitude(segment_coords),
      index(segment_coords)
    ),
    c(nrow(segment_coords), 3)
  )
  raw_result <- do.call(infostop::spatial_infomap, c(model_spec$params, list(data=data_mat, distance='euclidean')))
  segment_groupings <- to_grouping_label(raw_result$labels)
  og_data_groupings <- segment_groupings[segmentation_fit]
  attributes(og_data_groupings) <- list(
    #label_meta = label_meta, # now one row per grouping
    model_spec = model_spec,
    raw_fit = raw_result
  )
  class(og_data_groupings) <- c('stop_threshold_fit', 'travel_path_grouping_fit', 'travel_path_fit', class(labels))
  return(og_data_groupings)
}

# methods specifying data requirements
requires_segment_coords.info_map_model_spec <- function(...) TRUE



#  User code ---

if(FALSE) {
  abby_4652 <- read.csv("./data/FFT.csv") |>
    dplyr::filter(
      individual.local.identifier == "Abby",
      tag.local.identifier == 4652
    ) |>
    dplyr::mutate(timestamp = as.POSIXct(timestamp)) |>
    sf::st_as_sf(crs = 4326, coords = c("location.long", "location.lat"))
  tf <- as.track_frame(abby_4652, index='timestamp', lon_col='utm.easting', lat_col='utm.northing')
  saveRDS(tf, 'data/abby.csv')
} else {
  tf <- readRDS('data/abby.csv')
}

tf$segmentation <- travel_path_segment(
  tf,
  stop_threshold_model_spec(r1 = 10, min_staying_time = 12*60, max_time_between = 60*60)
)

tf$grouping <- travel_path_grouping(
  tf$segmentation,
  info_map_model_spec(r2 = 15)
)