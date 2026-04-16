suppressPackageStartupMessages({
  library("tinytest")
  library("trackframe")
  library("checkmate")
  library("travelpaths")
})

test_simulate_path_matrix <- function() {
  set.seed(2025)
  data_matrix <- sim_travel_path(100, format = "matrix")
  expect_inherits(data_matrix, "matrix")
  expect_equal(NROW(data_matrix), 100)
  expect_equal(NCOL(data_matrix), 4)
}


test_simulate_path_data_frame <- function() {
  set.seed(2025)
  data_df <- sim_travel_path(100, format = "data.frame")
  expect_inherits(data_df, "data.frame")
  expect_equal(NROW(data_df), 100)
  expect_equal(NCOL(data_df), 4)
}


test_simulate_path_trackframe <- function() {
  set.seed(2025)
  tf <- sim_travel_path(100, format = "trackframe")
  expect_true(all(c("time", "easting", "northing") %in% colnames(tf)))
  expect_inherits(tf, "trackframe")
  expect_equal(NROW(tf), 100)
  expect_equal(NCOL(tf), 4)
}


test_simulate_path_sftrack <- function() {
  set.seed(2025)
  sftrack <- sim_travel_path(100, format = "sftrack")
  expect_true(all(c("time", "easting", "easting") %in% colnames(sftrack)))
  expect_inherits(sftrack, "sftrack")
  expect_equal(NROW(sftrack), 100)
  expect_equal(NCOL(sftrack), 6)
}


test_simulate_path_move2 <- function() {
  set.seed(2025)
  move2 <- sim_travel_path(100, format = "move2")
  expect_true(all(c("time", "geometry") %in% colnames(move2)))
  expect_inherits(move2, "move2")
  expect_equal(NROW(move2), 100)
  expect_equal(NCOL(move2), 3)
}


test_simulate_paths <- function() {
  ntracks <- 3
  sizes <- c(2, 4, 5)
  multi_track <- sim_travel_paths(ntracks, sizes)
  expect_inherits(multi_track, "trackframe")
  expect_equal(sum(sizes), NROW(multi_track))
  expect_length(unique(id(multi_track)), ntracks)

  track2 <- select_id(multi_track, "track_2")
  expect_inherits(track2, "trackframe")
  expect_equal(NROW(track2), sizes[2])
  expect_length(unique(id(track2)), 1)

  multi_track_sftrack <- sim_travel_paths(ntracks, sizes, format = "sftrack")
  expect_inherits(multi_track_sftrack, "sftrack")
  expect_equal(sum(sizes), NROW(multi_track_sftrack))
  expect_length(unique(multi_track_sftrack[["id"]]), ntracks)

  expect_error(select_id(multi_track_sftrack, "track_2"))
}


# Run all tests
test_simulate_path_matrix()
test_simulate_path_data_frame()
test_simulate_path_trackframe()
test_simulate_path_sftrack()
test_simulate_path_move2()
test_simulate_paths()
