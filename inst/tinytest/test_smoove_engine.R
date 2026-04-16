suppressPackageStartupMessages({
  library("trackframe")
  library("travelpaths")
  library("tinytest")
  library("smoove")
  library("checkmate")
})
data(Kestrel)
k <- Kestrel[3900:4000, ]


suppressWarnings(data <- as.trackframe(k, easting_col = "X", northing_col = "Y", crs = NA))
plot(data)


data_cp <- cvm_estimate_change_points(
  data,
  windowsize = 50,
  windowstep = 5,
  model = "RACVM",
  progress = FALSE,
  time_unit = "secs",
  .parallel = FALSE,
  clusterwidth = NULL,
  verbose = FALSE
)
# which(data_cp$cp_id == 1)
expect_inherits(data_cp, "trackframe")
expect_equal(data_cp$cp_id[42], 1)
expect_equal(sum(data_cp$cp_id), 1)

data_cp_phase <- cvm_estimate_phases(data_cp, verbose = FALSE)

expect_inherits(data_cp_phase, "trackframe")
expect_true(all(data_cp_phase$phase_id[1:41] == "1"))
expect_true(all(data_cp_phase$phase_id[42:100] == "2"))


cpt_spec <- cvm_change_points(
  windowsize = 50,
  windowstep = 5,
  model = "RACVM",
  time_unit = "secs"
)

cpt_fit <- fit(cpt_spec, data, progress = FALSE, verbose = FALSE)
phases_spec <- cvm_phases()
phases <- fit(phases_spec, cpt_fit, verbose = FALSE)

expect_equal(unclass(cpt_fit), unclass(data_cp))
expect_equal(unclass(phases), unclass(data_cp_phase))

expect_silent(plot_phases(data_cp_phase))
expect_silent(summarize_phases(data_cp_phase))
