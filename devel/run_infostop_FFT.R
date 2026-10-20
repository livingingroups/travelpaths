library("travelpaths")
library("trackframe")

fft_file <- normalizePath("~/travel_paths/travel_paths/data/FFT.csv")
fft <- read.csv(fft_file)
fft$timestamp <- as.POSIXct(fft$timestamp, tz = "UTC")
cols <- c(
  "timestamp", "utm.easting", "utm.northing",
  "individual.local.identifier", "tag.local.identifier"
)
fft <- fft[, cols]
fft_abby <- fft[
  which(with(fft, individual.local.identifier == "Abby" & tag.local.identifier == 4652)),
]
dim(fft_abby)

tf <- as.trackframe(
  fft_abby,
  time_col = "timestamp",
  easting_col = "utm.easting",
  northing_col = "utm.northing",
  id_col = "individual.local.identifier",
  crs = "EPSG:32617"
)

stops_spec <- threshold_stops(
  r1 = 10,
  min_staying_time = 300L,
  max_time_between = 86400L
)
sites_spec <- infomap(r2 = 10)

stops <- fit(stops_spec, tf)
tf <- augment(stops, tf)
head(tf)

sites <- fit(sites_spec, tf)
class(sites)

# The fitted engine objects remain available through `fitted()`.
sites

# Inspect results through the travelpaths accessors.
dim(tf)[1]
dim(fitted(stops))[1]
n_segments(stops)
head(segment_meta(stops))

dim(fitted(sites))[1]
n_groups(sites)
group_meta(sites)

# Attach site labels to the original trackframe.
tf_result <- augment(sites, tf)
head(tf_result)

# Plot only fixes assigned to a site. Mapping the full trackframe is too
# dense because it includes all non-site fixes and their connecting paths.
tf_result_sites <- tf_result[!is.na(tf_result[["site_id"]]), ]
map_utm <- plot_map(tf_result_sites, group_col = "site_id", scatter = TRUE)
htmlwidgets::saveWidget(map_utm, "/tmp/fft_sites_utm.html", selfcontained = TRUE)

# The longitude/latitude trackframe is only used for haversine calculations.
# Convert it to sf explicitly before mapping. Its easting/northing columns
# contain latitude/longitude respectively, so reverse them for sf coordinates.
tf_lon_lat_stops_sf <- sf::st_as_sf(
  as.data.frame(tf_lon_lat_stops),
  coords = c("northing", "easting"),
  crs = 4326,
  remove = FALSE
)
map_lon_lat <- plot_map(tf_lon_lat_stops_sf, group_col = "stop_id", scatter = TRUE)
htmlwidgets::saveWidget(map_lon_lat, "/tmp/fft_stops_lon_lat.html", selfcontained = TRUE)
