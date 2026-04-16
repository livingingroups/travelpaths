library("trackframe")

pkg_dir <- normalizePath("..")
data_dir <- file.path(pkg_dir, "data")

source(file.path(pkg_dir, "R/random_track_frame.R"))

dir.create(data_dir, showWarnings = FALSE)

#
# Simulate Single Path
#
set.seed(2025)
travel_path_matrix <- sim_travel_path(size = 1000, format = "matrix")
save(travel_path_matrix, file = file.path(data_dir, "travel_path_matrix.rda"))

set.seed(2025)
travel_path_data_frame <- sim_travel_path(size = 1000, format = "data.frame")
save(travel_path_data_frame, file = file.path(data_dir, "travel_path_data_frame.rda"))

set.seed(2025)
travel_path_trackframe <- sim_travel_path(size = 1000, format = "trackframe")
save(travel_path_trackframe, file = file.path(data_dir, "travel_path_trackframe.rda"))

set.seed(2025)
travel_path_sftrack <- sim_travel_path(size = 1000, format = "sftrack")
save(travel_path_sftrack, file = file.path(data_dir, "travel_path_sftrack.rda"))

set.seed(2025)
travel_path_move2 <- sim_travel_path(size = 1000, format = "move2")
save(travel_path_move2, file = file.path(data_dir, "travel_path_move2.rda"))

#
# Simplulate Multiple Paths
#
set.seed(2025)
travel_paths_matrix <- sim_travel_paths(ntracks = 3, size = 1000, format = "matrix")
save(travel_paths_matrix, file = file.path(data_dir, "travel_paths_matrix.rda"))

set.seed(2025)
travel_paths_data_frame <- sim_travel_paths(ntracks = 3, size = 1000, format = "data.frame")
save(travel_paths_data_frame, file = file.path(data_dir, "travel_paths_data_frame.rda"))

set.seed(2025)
travel_paths_trackframe <- sim_travel_paths(ntracks = 3, size = 1000, format = "trackframe")
save(travel_paths_trackframe, file = file.path(data_dir, "travel_paths_trackframe.rda"))

set.seed(2025)
travel_paths_sftrack <- sim_travel_paths(ntracks = 3, size = 1000, format = "sftrack")
save(travel_paths_sftrack, file = file.path(data_dir, "travel_paths_sftrack.rda"))

set.seed(2025)
travel_paths_move2 <- sim_travel_paths(ntracks = 3, size = 1000, format = "move2")
save(travel_paths_move2, file = file.path(data_dir, "travel_paths_move2.rda"))
