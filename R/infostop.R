#' Threshold-based Stop Detection
#'
#' @description
#'
#' `threshold_stops()` defines a model that identifies stops in movement data
#' based on distance and time thresholds. This method detects stationary
#' periods by grouping consecutive points that are within a specified distance
#' and time criteria.
#'
#' There are different ways to fit this model, and the method of estimation is
#' chosen by setting the model engine. The engine-specific pages for this model
#' are listed below.
#'
#' - \code{infostop::identify_stops}: Threshold-based stop detection
#'
#' @param mode a character vector of length one, for the type of model. The only
#'   possible value for this model is "stops".
#' @param engine a character vector of length one, specifying what computational engine
#'   to use for fitting. Possible engines are listed below. The default for this
#'   model is `"infostop"`.
#' @param r1 A positive numeric value giving the maximum distance between
#'   time-consecutive points to label them as stationary. Higher values will
#'   result in more points being considered stationary.
#' @param min_size A positive integer giving the minimum number of points
#'   required to consider a group stationary.
#' @param min_staying_time A positive integer giving the minimum duration
#'   (in seconds) that can constitute a stop. Only relevant if timestamps
#'   are provided in the data.
#' @param max_time_between A positive integer giving the maximum duration
#'   (in seconds) between consecutive points to consider them part of the
#'   same stop. Only relevant if timestamps are provided.
#' @param output_col a character vector of length one, specifying the name of the
#'   column to be used for the stop identifiers. Default is "stop_id".
#'
#' @details
#'
#' ## What does it mean to predict?
#'
#' For a threshold-based stop detection model, stops are identified by grouping
#' consecutive points that meet the distance and time criteria. Therefore,
#' prediction in travelpaths assigns stop identifiers to movement trajectory
#' points based on these threshold conditions.
#'
#' @return A `threshold_stops` specification.
#'
#' @examples
#' threshold_stops()
#'
#' # Specify distance metric and parameters
#' ths_spec <- threshold_stops(
#'   r1 = 20,
#'   min_size = 3
#' )
#' @export
threshold_stops <- function(
  mode = "segmentation",
  engine = "infostop",
  r1 = 10,
  min_size = 2L,
  min_staying_time = 300L,
  max_time_between = 86400L,
  output_col = "stop_id"
) {
  args <- list(
    r1 = r1,
    min_size = min_size,
    min_staying_time = min_staying_time,
    max_time_between = max_time_between,
    stop_id_col = output_col
  )
  new_travelpath_spec(
    "threshold_stops",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}


#' Infomap Site Identification
#'
#' @description
#'
#' `infomap()` defines a model that identifies sites from movement stops using
#' the Infomap community detection algorithm. This method clusters spatially
#' proximate stops into meaningful sites by creating a network of stops and
#' applying information-theoretic community detection.
#'
#' There are different ways to fit this model, and the method of estimation is
#' chosen by setting the model engine. The engine-specific pages for this model
#' are listed below.
#'
#' - \code{infostop::identify_sites}: Infomap-based site identification
#'
#' @param mode A character string for the type of model. The only
#'   possible value for this model is "grouping".
#' @param engine A character string specifying what computational engine
#'   to use for fitting. Possible engines are listed below. The default for this
#'   model is `"infostop"`.
#' @param r2 A positive numeric value giving the maximum distance between
#'   stationary points to form an edge in the network representation.
#' @param label_singleton A logical value. If TRUE, give stationary locations
#'   that were only visited once their own label. If FALSE, label them as
#'   non-stationary (-1).
#' @param min_spacial_resolution A numeric value giving the minimal difference
#'   allowed between points before they are considered the same points.
#' @param weighted A logical value. If TRUE, weight edges in the network
#'   representation by distance.
#' @param weight_exponent A positive numeric value giving the exponent used
#'   when weighting edges in the network.
#' @param stop_id_col A character string specifying the name of the
#'   column to be used for the stop identifiers. Default is "stop_id".
#' @param output_col A character string specifying the name of the
#'   column to be used for the site identifiers. Default is "site_id".
#'
#' @return An `infomap` specification.
#'
#' @examples
#' infomap()
#'
#' infomap(
#'   r2 = 50,
#'   weighted = TRUE
#' )
#' @export
infomap <- function(
  mode = "grouping",
  engine = "infostop",
  r2 = 10,
  label_singleton = TRUE,
  min_spacial_resolution = 0,
  weighted = FALSE,
  weight_exponent = 1,
  stop_id_col = "stop_id",
  output_col = "site_id"
) {
  args <- list(
    r2 = r2,
    label_singleton = label_singleton,
    min_spacial_resolution = min_spacial_resolution,
    weighted = weighted,
    weight_exponent = weight_exponent,
    stop_id_col = stop_id_col,
    site_id_col = output_col
  )
  new_travelpath_spec(
    "infomap",
    args = args,
    eng_args = list(),
    mode = mode,
    engine = engine
  )
}
