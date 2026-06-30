
.infostop_identify_stops_meta <- function(data, stop_id_col) {
  idcol <- id_col(data)
  e_col <- easting_col(data)
  n_col <- northing_col(data)
  t_col <- time_col(data)
  cols <- c(stop_id_col, idcol, e_col, n_col, t_col)
  stop_data <- data[!is.na(data[[stop_id_col]]), cols]
  split_id <- sprintf("%s__%s", stop_data[[idcol]], stop_data[[stop_id_col]])
  splitted <- split(stop_data, split_id)
  start_time <- unlist(lapply(splitted, function(x) min(x[[t_col]])))
  stop_time <- unlist(lapply(splitted, function(x) max(x[[t_col]])))
  attributes(start_time) <- attributes(stop_time) <- attributes(data[[t_col]])
  event_track_id <- unlist(lapply(splitted, function(x) head(x[[idcol]], 1)), FALSE, FALSE)
  event_stop_id <- unlist(lapply(splitted, function(x) head(x[[stop_id_col]], 1)), FALSE, FALSE)
  stop_events <- data.frame(
    id = event_track_id,
    stop_id = event_stop_id,
    n_points = lengths(splitted),
    easting = as.numeric(lapply(splitted, function(x) mean(x[[e_col]]))),
    northing = as.numeric(lapply(splitted, function(x) mean(x[[n_col]]))),
    start_time = start_time,
    stop_time = stop_time
  )
  rownames(stop_events) <- NULL
  number_of_segments <- function(x) {
    sum(unique(x) > 0, na.rm = TRUE)
  }
  n_segments <- lapply(split(stop_events[["stop_id"]], stop_events[["id"]]), number_of_segments)
  meta <- list(
    n_segments = setNames(as.integer(n_segments), names(n_segments))
  )
  meta[[stop_id_col]] <- stop_events
  meta
}


.infostop_identify_stops <- function(
  data,
  r1 = 10,
  min_size = 2L,
  min_staying_time = 300L,
  max_time_between = 86400L,
  output_col = "stop_id",
  ...
) {
  fitted <- infostop::identify_stops(
    data,
    r1 = r1,
    min_size = min_size,
    min_staying_time = min_staying_time,
    max_time_between = max_time_between,
    output_col = output_col,
    ...
  )
  list(
    fit = fitted,
    preproc = list(),
    meta = .infostop_identify_stops_meta(fitted, stop_id_col = output_col)
  )
}


.infostop_identify_sites_meta <- function(data, site_id_col) {
  cols <- c(site_id_col, "easting", "northing")
  site_data <- data[!is.na(data[[site_id_col]]), cols]
  splitted <- split(site_data, site_data[[site_id_col]])
  site_id <- unlist(lapply(splitted, function(x) head(x[[site_id_col]], 1)))
  site_data <- data.frame(
    id = site_id,
    n_points = as.integer(lapply(splitted, NROW)),
    easting = as.numeric(lapply(splitted, function(x) mean(x[["easting"]]))),
    northing = as.numeric(lapply(splitted, function(x) mean(x[["northing"]])))
  )
  colnames(site_data)[1L] <- site_id_col
  meta <- list(
    n_groups = sum(unique(data[[site_id_col]]) > 0, na.rm = TRUE)
  )
  meta[[site_id_col]] <- site_data
  meta
}


.infostop_identify_sites <- function(
  data,
  r2 = 10,
  label_singleton = TRUE,
  min_spacial_resolution = 0,
  weighted = FALSE,
  weight_exponent = 1,
  stop_id_col = "stop_id",
  output_col = "site_id",
  ...
) {
  fitted <- infostop::identify_sites(
    data,
    r2 = r2,
    label_singleton = label_singleton,
    min_spacial_resolution = min_spacial_resolution,
    weighted = weighted,
    weight_exponent = weight_exponent,
    stop_id_col = stop_id_col,
    output_col = output_col,
    ...
  )
  list(
    fit = fitted,
    preproc = list(),
    meta = .infostop_identify_sites_meta(fitted, output_col)
  )
}
