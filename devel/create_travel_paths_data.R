library(trackframe) #FIXME: remove once transferred to travelpaths
# library(travelpaths)
set.seed(2025)
travel_path_matrix <- sim_travel_path(size = 1000, format = "matrix")
save(travel_path_matrix, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_path_matrix.rda")

set.seed(2025)
travel_path_data_frame <- sim_travel_path(size = 1000, format = "data.frame")
save(travel_path_data_frame, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_path_data_frame.rda")

set.seed(2025)
travel_path_track_frame <- sim_travel_path(size = 1000, format = "track_frame")
save(travel_path_track_frame, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_path_track_frame.rda")

set.seed(2025)
travel_path_sftrack <- sim_travel_path(size = 1000, format = "sftrack")
save(travel_path_sftrack, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_path_sftrack.rda")

set.seed(2025)
travel_path_move2 <- sim_travel_path(size = 1000, format = "move2")
save(travel_path_move2, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_path_move2.rda")


#simulate_travel_paths
set.seed(2025)
travel_paths_matrix <- sim_travel_paths(ntracks = 3, size = 1000, format = "matrix")
save(travel_paths_matrix, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_paths_matrix.rda")

set.seed(2025)
travel_paths_data_frame <- sim_travel_paths(ntracks = 3, size = 1000, format = "data.frame")
save(travel_paths_data_frame, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_paths_data_frame.rda")

set.seed(2025)
travel_paths_track_frame <- sim_travel_paths(ntracks = 3, size = 1000, format = "track_frame")
save(travel_paths_track_frame, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_paths_track_frame.rda")

set.seed(2025)
travel_paths_sftrack <- sim_travel_paths(ntracks = 3, size = 1000, format = "sftrack")
save(travel_paths_sftrack, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_paths_sftrack.rda")

set.seed(2025)
travel_paths_move2 <- sim_travel_paths(ntracks = 3, size = 1000, format = "move2")
save(travel_paths_move2, file = "~/travelpaths-devel/pkgs/travelpaths/data/travel_paths_move2.rda")