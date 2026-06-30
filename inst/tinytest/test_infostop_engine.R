suppressPackageStartupMessages({
  library("tinytest")
  library("checkmate")
  library("trackframe")
  library("travelpaths")
})

if (!isTRUE(requireNamespace("infostop", quietly = TRUE))) {
  exit_file("Could not find package 'infostop'!")
}


# NOTE:
# We should also ship the data in "tinytest/data/tf_paths.RData" with infostop.
# The current data has longitude/latitude values in the columns
# labelled northing / easting.
#> data("path_trackframe", package = "trackframe")
#> path_tf <- path_trackframe
load(system.file("tinytest/data/tf_paths.RData", package = "infostop"))


#
# Compare API Results Stops
#

# infostop
target_stops <- infostop::identify_stops(path_trackframe)

# travelpaths
stops_spec <- threshold_stops()
stops_fit  <- fit(stops_spec, path_trackframe)
expect_equal(fitted(stops_fit)$stop_id, target_stops$stop_id)


#
# Compare API Results Sites
#
# infostop
target_sites <- infostop::identify_sites(target_stops, r2 = 50)

# travelpaths
sites_spec <- infomap(r2 = 50)
sites_fit  <- fit(sites_spec, augment(stops_fit, path_trackframe))
expect_equal(fitted(sites_fit)$site_id, target_sites$site_id)


#
# Test Accessors Stops
#
expect_equal(specification(stops_fit), stops_spec)
expect_equal(
  unname(n_segments(stops_fit)),
  length(unique(na.omit(target_stops$stop_id)))
)
expect_numeric(elapsed(stops_fit))
expect_equal(segment_col(stops_fit), "stop_id")
expect_equal(NROW(segment_meta(stops_fit)), unname(n_segments(stops_fit)))

# Attach the stop column back onto the trackframe.
tf <- augment(stops_fit, path_trackframe)
expect_choice("stop_id", colnames(tf))

# Use it multiple times
tf <- augment(stops_fit, path_trackframe, output_col = "stop_id_1")
tf <- augment(stops_fit, tf, output_col = "stop_id_2")
tf <- augment(stops_fit, tf, output_col = "stop_id_3")
expect_true(all(sprintf("stop_id_%i", 1:3) %in% colnames(tf)))

# Arguments from spec shows all the arguments of the fit function
expect_class(arguments(stops_spec), "function_arguments")


#
# Test Accessors Sites
#
expect_equal(specification(sites_fit), sites_spec)
expect_equal(n_groups(sites_fit), length(unique(na.omit(target_sites$site_id))))
expect_numeric(elapsed(sites_fit))
expect_equal(group_col(sites_fit), "site_id")
expect_equal(NROW(group_meta(sites_fit)), n_groups(sites_fit))

# Attach the site_id column back onto the trackframe.
tf <- augment(sites_fit, path_trackframe)
expect_choice("site_id", colnames(tf))

# Use it multiple times
tf <- augment(sites_fit, path_trackframe, output_col = "site_id_1")
tf <- augment(sites_fit, tf, output_col = "site_id_2")
tf <- augment(sites_fit, tf, output_col = "site_id_3")
expect_true(all(sprintf("site_id_%i", 1:3) %in% colnames(tf)))

# Arguments from spec shows all the arguments of the fit function
expect_class(arguments(sites_spec), "function_arguments")
