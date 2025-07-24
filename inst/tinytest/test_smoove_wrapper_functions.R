library(tinytest)
library(smoove)
# compare estimate_ucvm with smoove::estimateUCVM
set.seed(2025)
tf <- sim_travel_path(100, format = "track_frame", max_step = 0.01, stay_prob = 0.3, time_increment = 60)
Z = cbind(easting(tf), northing(tf))
T = as.POSIXct(time(tf))

smoove_estimateUCVM <- smoove::estimateUCVM(Z, T, time.units = "min")
travelpaths_estimate_ucvm <- estimate_ucvm(tf)
expect_equal(travelpaths_estimate_ucvm, smoove_estimateUCVM)

smoove_estimateUCVM2 <- smoove::estimateUCVM(Z, T, method = "vLike", time.units = "min", CI = TRUE)
travelpaths_estimate_ucvm2 <- estimate_ucvm(tf, CI = TRUE)
expect_equal(travelpaths_estimate_ucvm2, smoove_estimateUCVM2)

set.seed(2025)
tf_equi <- sim_travel_path(100, format = "track_frame", max_step = 0.01, stay_prob = 0, time_increment = 60)
Z_equi = cbind(easting(tf_equi), northing(tf_equi))
T_equi = as.POSIXct(time(tf_equi))

smoove_estimateUCVM_vaf <- smoove::estimateUCVM(Z_equi, T_equi, method = "vaf", time.units = "min")
travelpaths_estimate_ucvm_vaf <- estimate_ucvm(tf_equi, method = "vaf")
expect_equal(travelpaths_estimate_ucvm_vaf, smoove_estimateUCVM_vaf)
expect_error(estimate_ucvm(tf, method = "vaf"))

smoove_estimateUCVM_crw <- smoove::estimateUCVM(Z_equi, T_equi, method = "crw", time.units = "min")
travelpaths_estimate_ucvm_crw <- estimate_ucvm(tf_equi, method = "crw")
expect_equal(travelpaths_estimate_ucvm_crw, smoove_estimateUCVM_crw)

smoove_estimateUCVM_crw2 <- smoove::estimateUCVM(Z, T, method = "crw", time.units = "min")
travelpaths_estimate_ucvm_crw2 <- estimate_ucvm(tf, method = "crw")
expect_equal(travelpaths_estimate_ucvm_crw2, smoove_estimateUCVM_crw2)

smoove_estimateUCVM_zLike <- smoove::estimateUCVM(Z, T, method = "zLike", time.units = "min")
travelpaths_estimate_ucvm_zLike <- estimate_ucvm(tf, method = "zLike")
expect_equal(travelpaths_estimate_ucvm_zLike, smoove_estimateUCVM_zLike)

set.seed(2025)
smoove_estimateUCVM_crawl <- smoove::estimateUCVM(Z_equi, T_equi, method = "crawl", time.units = "min")
set.seed(2025)
travelpaths_estimate_ucvm_crawl <- estimate_ucvm(tf_equi, method = "crawl")
expect_equal(travelpaths_estimate_ucvm_crawl, smoove_estimateUCVM_crawl)


set.seed(2025)
df <- sim_travel_path(100, format = "data.frame", max_step = 0.01, stay_prob = 0.3, time_increment = 60)
Z_df = cbind(df$longitude, df$latitude)
T_df = as.POSIXct(df$time)

smoove_estimateUCVM <- smoove::estimateUCVM(Z_df, T_df, time.units = "min")
travelpaths_estimate_ucvm <- estimate_ucvm(df)
expect_equal(travelpaths_estimate_ucvm, smoove_estimateUCVM)


# diagnose_crw
smoove_DiagnoseCRW <- smoove:::DiagnoseCRW(Z)
travelpaths_diagnose_crw <- diagnose_crw(tf)
expect_equal(travelpaths_diagnose_crw, smoove_DiagnoseCRW)

smoove_DiagnoseCRW_df <- smoove:::DiagnoseCRW(Z_df)
travelpaths_diagnose_crw_df <- diagnose_crw(df)
expect_equal(travelpaths_diagnose_crw_df, smoove_DiagnoseCRW_df)

# estimate_racvm
smoove::estimateRACVM
smoove_estimateRACVM <- smoove::estimateRACVM(Z, T, time.units = "min")
travelpaths_estimate_racvm <- estimate_racvm(tf)
expect_equal(travelpaths_estimate_racvm, smoove_estimateRACVM)

smoove_estimateRACVM_ucvm <- smoove::estimateRACVM(Z, T, time.units = "min", model = "UCVM")
travelpaths_estimate_ucvm <- estimate_racvm(tf, model = "UCVM")
expect_equal(travelpaths_estimate_ucvm, smoove_estimateRACVM_ucvm)

smoove_estimateRACVM_acvm <- smoove::estimateRACVM(Z, T, time.units = "min", model = "ACVM")
travelpaths_estimate_acvm <- estimate_racvm(tf, model = "ACVM")
expect_equal(travelpaths_estimate_acvm, smoove_estimateRACVM_acvm)

smoove_estimateRACVM_rcvm <- smoove::estimateRACVM(Z, T, time.units = "min", model = "RCVM")
travelpaths_estimate_rcvm <- estimate_racvm(tf, model = "RCVM")
expect_equal(travelpaths_estimate_rcvm, smoove_estimateRACVM_rcvm)


#sweep_racvm TODO

# test_cp
set.seed(2025)
tf_test <- sim_travel_path(1000, format = "track_frame")
# Z_test = cbind(easting(tf_test), northing(tf_test))
# T_test = as.POSIXct(time(tf_test))
Z_test = easting(tf_test) + 1i* northing(tf_test) #Z = cbind(easting(data), northing(data)), #T = time(data),
T_test = as.numeric(difftime(time(tf_test), time(tf_test)[1], units = "min"))#as.POSIXct(time(data)),
# set.seed(2025)
smoove_testCP <- smoove::testCP(Z_test, T_test, 10, 1, 100)
# set.seed(2025)
travelpaths_test_cp <- test_cp(tf_test, 10, 1, 100)
expect_equal(travelpaths_test_cp, smoove_testCP)


# find_single_break_point

set.seed(2025)
tf_fsb <- sim_travel_path(50, format = "track_frame")
Z2 = easting(tf_fsb) + 1i* northing(tf_fsb) #cbind(easting(data), northing(data)), #T = time(data),
T2 = as.numeric(difftime(time(tf_fsb), time(tf_fsb)[1], units = "min"))

smoove_findSingleBreakPoint <- smoove::findSingleBreakPoint(Z2, T2, method = "sweep")
travelpaths_find_single_break_point <- find_single_break_point(tf_fsb, method = "sweep")
expect_equal(travelpaths_find_single_break_point, smoove_findSingleBreakPoint)

smoove_findSingleBreakPoint_optim <- smoove::findSingleBreakPoint(Z2, T2, method = "optimize")
travelpaths_find_single_break_point_optim <- find_single_break_point(tf_fsb, method = "optimize")
expect_equal(travelpaths_find_single_break_point_optim, smoove_findSingleBreakPoint_optim)
