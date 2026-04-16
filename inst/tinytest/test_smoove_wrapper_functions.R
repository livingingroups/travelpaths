suppressPackageStartupMessages({
  library(tinytest)
  library(travelpaths)
  library(smoove)
})


hush <- function(expression) {
  invisible(capture.output(suppressMessages(expression)))
}


# compare estimate_ucvm with smoove::estimateUCVM
set.seed(2025)
tf <- sim_travel_path(
  100,
  format = "trackframe",
  max_step = 0.01,
  stay_prob = 0.3,
  time_increment = 60
)
z <- cbind(easting(tf), northing(tf))
z_t <- as.POSIXct(time(tf))

smoove_estimate_ucvm <- smoove::estimateUCVM(z, z_t, time.units = "min")
travelpaths_estimate_ucvm <- estimate_ucvm(tf)
expect_equal(travelpaths_estimate_ucvm, smoove_estimate_ucvm)

smoove_estimate_ucvm2 <- smoove::estimateUCVM(z, z_t, method = "vLike", time.units = "min",
  CI = TRUE)
travelpaths_estimate_ucvm2 <- estimate_ucvm(tf, ci = TRUE)
expect_equal(travelpaths_estimate_ucvm2, smoove_estimate_ucvm2)

set.seed(2025)
tf_equi <- sim_travel_path(
  100,
  format = "trackframe",
  max_step = 0.01,
  stay_prob = 0,
  time_increment = 60
)
z_equi <- cbind(easting(tf_equi), northing(tf_equi))
t_equi <- as.POSIXct(time(tf_equi))

smoove_estimate_ucvm_vaf <- smoove::estimateUCVM(z_equi, t_equi, method = "vaf", time.units = "min")
travelpaths_estimate_ucvm_vaf <- estimate_ucvm(tf_equi, method = "vaf")
expect_equal(travelpaths_estimate_ucvm_vaf, smoove_estimate_ucvm_vaf)
expect_error(estimate_ucvm(tf, method = "vaf"))

smoove_estimate_ucvm_crw <- smoove::estimateUCVM(z_equi, t_equi, method = "crw", time.units = "min")
travelpaths_estimate_ucvm_crw <- estimate_ucvm(tf_equi, method = "crw")
expect_equal(travelpaths_estimate_ucvm_crw, smoove_estimate_ucvm_crw)

smoove_estimate_ucvm_crw2 <- smoove::estimateUCVM(z, z_t, method = "crw", time.units = "min")
travelpaths_estimate_ucvm_crw2 <- estimate_ucvm(tf, method = "crw")
expect_equal(travelpaths_estimate_ucvm_crw2, smoove_estimate_ucvm_crw2)

smoove_estimate_ucvm_zlike <- smoove::estimateUCVM(z, z_t, method = "zLike", time.units = "min") #nolint
tp_estimate_ucvm_zlike <- estimate_ucvm(tf, method = "zLike")
expect_equal(tp_estimate_ucvm_zlike, smoove_estimate_ucvm_zlike)

set.seed(2025)
hush(
  smoove_estimate_ucvm_crawl <- smoove::estimateUCVM(
    z_equi,
    t_equi,
    method = "crawl",
    time.units = "min"
  )
)
set.seed(2025)
hush(tp_estimate_ucvm_crawl <- estimate_ucvm(tf_equi, method = "crawl"))
expect_equal(tp_estimate_ucvm_crawl, smoove_estimate_ucvm_crawl)



data("path_trackframe", package = "trackframe")
df <- path_trackframe

z_df <- cbind(df$easting, df$northing)
t_df <- as.POSIXct(df$time)

smoove_estimate_ucvm <- smoove::estimateUCVM(z_df, t_df, time.units = "min")
travelpaths_estimate_ucvm <- estimate_ucvm(df)
expect_equal(travelpaths_estimate_ucvm, smoove_estimate_ucvm)


# diagnose_crw
smoove_diagnose_crw <- smoove:::DiagnoseCRW(z)
travelpaths_diagnose_crw <- diagnose_crw(tf)
expect_equal(travelpaths_diagnose_crw, smoove_diagnose_crw)

smoove_diagnose_crw_df <- smoove:::DiagnoseCRW(z_df)
travelpaths_diagnose_crw_df <- diagnose_crw(df)
expect_equal(travelpaths_diagnose_crw_df, smoove_diagnose_crw_df)

# estimate_racvm
smoove_estimate_racvm <- smoove::estimateRACVM(z, z_t, time.units = "min")
travelpaths_estimate_racvm <- estimate_racvm(tf)
expect_equal(travelpaths_estimate_racvm, smoove_estimate_racvm)

smoove_estimate_racvm_ucvm <- smoove::estimateRACVM(z, z_t, time.units = "min", model = "UCVM")
travelpaths_estimate_ucvm <- estimate_racvm(tf, model = "UCVM")
expect_equal(travelpaths_estimate_ucvm, smoove_estimate_racvm_ucvm)

smoove_estimate_racvm_acvm <- smoove::estimateRACVM(z, z_t, time.units = "min", model = "ACVM")
travelpaths_estimate_acvm <- estimate_racvm(tf, model = "ACVM")
expect_equal(travelpaths_estimate_acvm, smoove_estimate_racvm_acvm)

smoove_estimate_racvm_rcvm <- smoove::estimateRACVM(z, z_t, time.units = "min", model = "RCVM")
travelpaths_estimate_rcvm <- estimate_racvm(tf, model = "RCVM")
expect_equal(travelpaths_estimate_rcvm, smoove_estimate_racvm_rcvm)


#sweep_racvm
smooce_sweep_racvm <- smoove::sweepRACVM(z_df, t_df, windowsize = 1000, windowstep = 1000,
  model = "UCVM", progress = FALSE, time.unit = "mins", .parallel = FALSE)
tp_sweep_racvm <- sweep_racvm(df, windowsize = 1000, windowstep = 1000, model = "UCVM",
  progress = FALSE, time_unit = "mins", .parallel = FALSE)
expect_equal(tp_sweep_racvm, smooce_sweep_racvm)

# test_cp
set.seed(2025)
tf_test <- sim_travel_path(1000, format = "trackframe")
z_test <- easting(tf_test) + 1i * northing(tf_test)
t_test <- as.numeric(difftime(time(tf_test), time(tf_test)[1], units = "min"))
# set.seed(2025)
smoove_test_cp <- smoove::testCP(z_test, t_test, 10, 1, 100)
# set.seed(2025)
travelpaths_test_cp <- test_cp(tf_test, 10, 1, 100)
expect_equal(travelpaths_test_cp, smoove_test_cp)


# find_single_break_point

set.seed(2025)
tf_fsb <- sim_travel_path(50, format = "trackframe")
z2 <- easting(tf_fsb) + 1i * northing(tf_fsb)
z_t <- as.numeric(difftime(time(tf_fsb), time(tf_fsb)[1], units = "min"))

smoove_find_sbp <- smoove::findSingleBreakPoint(z2, z_t, method = "sweep")
tp_find_sbp <- find_single_break_point(tf_fsb, method = "sweep")
expect_equal(tp_find_sbp, smoove_find_sbp)

smoove_find_sbp_optim <- smoove::findSingleBreakPoint(z2, z_t, method = "optimize")
tp_find_sbp_optim <- find_single_break_point(tf_fsb, method = "optimize")
expect_equal(tp_find_sbp_optim, smoove_find_sbp_optim)
