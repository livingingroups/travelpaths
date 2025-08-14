# library(tinytest)
# Test Suite for change_point_test Function
library(trackframe)

# cpttestdata

test_simulate_path <- function() {
  set.seed(2025)
  data_matrix <- sim_travel_path(100, format = "matrix")
  expect_inherits(data_matrix, "matrix")
  expect_equal(NROW(data_matrix), 100)
  expect_equal(NCOL(data_matrix), 4)
  
  set.seed(2025)
  data_df <- sim_travel_path(100, format = "data.frame")
  expect_inherits(data_df, "data.frame")
  expect_equal(NROW(data_df), 100)
  expect_equal(NCOL(data_df), 4)
  
  set.seed(2025)
  tf <- sim_travel_path(100, format = "trackframe")
  expect_true(all(c("time", "easting", "northing") %in% colnames(tf)))
  expect_inherits(tf, "trackframe")
  expect_equal(NROW(tf), 100)
  expect_equal(NCOL(tf), 6)
  expect_equal(easting(tf), tf$easting)
  expect_equal(northing(tf), tf$northing)
  expect_equal(time(tf), tf$time)
  
  #sftrack
  set.seed(2025)
  sftrack <- sim_travel_path(100, format = "sftrack")
  expect_true(all(c("time", "latitude", "longitude") %in% colnames(sftrack)))
  expect_inherits(sftrack, "sftrack")
  expect_equal(NROW(sftrack), 100)
  expect_equal(NCOL(sftrack), 6)
  expect_equal(sf::st_coordinates(sftrack),
               cbind("X" = sftrack[["latitude"]],
                     "Y" = sftrack[["longitude"]]))

  # move2
  set.seed(2025)
  move2 <- sim_travel_path(100, format = "move2")
  expect_true(all(c("time", "geometry") %in% colnames(move2)))
  expect_inherits(move2, "move2")
  expect_equal(NROW(move2), 100)
  expect_equal(NCOL(move2), 3)
  expect_equal(sf::st_coordinates(move2),
               cbind("X" = sftrack[["latitude"]],
                     "Y" = sftrack[["longitude"]]))
  
  
  expect_equal(sf::st_coordinates(move2),
               cbind("X" = data_matrix[,"latitude"],
                     "Y" = data_matrix[,"longitude"]))
  
  expect_equal(sf::st_coordinates(move2),
               cbind("X" = data_df[,"latitude"],
                     "Y" = data_df[,"longitude"]))
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
test_simulate_path()
test_simulate_paths()

cat("All tests for simulate paths completed successfully!\n")
