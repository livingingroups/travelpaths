# load packages
library(travelpaths)
# library(smoove)

# set wd as path folder
setwd("~/travelpaths-devel/pkgs/travelpaths/devel")

# load data
FFT <- read.csv(file.path("..", "..", "..", "data", "FFT.csv"))

# travelpaths:::as.trackframe.data.frame
FFT$timestamp <- as.POSIXct(FFT$timestamp) #need Posixct timestamp
FFT_tf <- as.trackframe(FFT,
  time_col  = "timestamp",
  easting_col = "utm.easting",
  northing_col = "utm.northing",
  id_col = "individual.local.identifier",
  crs = NA
)

str(FFT_tf)
dim(FFT_tf)


# FFT_tf_abby <- select_id(tf = FFT_tf, id = "Abby")
FFT_tf_abby <- dplyr::filter(FFT_tf, individual.local.identifier == "Abby", tag.local.identifier == 4652)
# FFT_tf_abby <- select_id(tf = FFT_tf, id = c("Abby", "4652"))
dim(FFT_tf_abby)

tf <- FFT_tf_abby
class(tf)

head(index(tf))
head(easting(tf))
head(northing(tf))

# smoove::estimateUCVM
# works - important to set time.units = "min"
# "vaf", "crw" only works with equidistant time points - resampling does not work for FFT data
# we use only "vLike" and "crawl"
fit_vLike <- estimate_ucvm(data = FFT_tf_abby,  method = "vLike", time.units = "min")
set.seed(2025) #does not work for every seed
fit_crawl <- estimate_ucvm(data = FFT_tf_abby,  method = "crawl", time.units = "min") 
# fit_zLike <- estimate_ucvm(data = FFT_tf_abby,  method = "zLike", time.units = "min") #very slow
fit_vLike
fit_crawl
# fit_zLike


# smoove:::DiagnoseCRW
diagnose_crw(tf)


# smoove::estimateRACVM
fit_racvm <- estimate_racvm(data = FFT_tf_abby, time.units = "min")
fit_racvm


# smoove::sweepRACVM
# IMPORTANT be aware time unit "mins" vs. "min" in other functions
# S3 method exists
# time window of analysis to scan, IMPORTANTLY: in units of time (T).

# windowsize and window step chosen arbitrarily - windowsize one day and windowstep 1 hour
if (FALSE){
  require(foreach)
  require(doParallel)
  cl <- makeCluster(detectCores()-4)
  registerDoParallel(cl)
  sweep_tf <- sweep_racvm(data = tf, windowsize = 24*60, windowstep = 60, .parallel = TRUE, time.unit = "mins") #!!!mins
  saveRDS(sweep_tf, '../../../cvm/sweep_tf.rds')
} else {
  sweep_tf <- readRDS('../../../cvm/sweep_tf.rds')
}

str(sweep_tf)
smoove::plotWindowSweep(sweep_tf)


# Get candidate change points
# 2.3.2 II

# Change point analysis
CP.all <- smoove::findCandidateChangePoints(windowsweep = sweep_tf)

str(CP.all)
# 487 cp

CP.4 <- smoove::findCandidateChangePoints(windowsweep = sweep_tf, clusterwidth = 4)
CP.150 <- smoove::findCandidateChangePoints(windowsweep = sweep_tf, clusterwidth = 150)
CP.180 <- smoove::findCandidateChangePoints(windowsweep = sweep_tf, clusterwidth = 180)
CP.188 <- smoove::findCandidateChangePoints(windowsweep = sweep_tf, clusterwidth = 188) # 202 cp 

# smoove::findCandidateChangePoints(windowsweep = sweep_tf, clusterwidth = 1000) # 202 cp 

# Select significant changepoints
# 3.2.3 III

cp_table <- smoove::getCPtable(CPs = CP.188, modelset = 'UCVM')
dim(cp_table)
# 12, 9
cp_table

cp_table_i <- smoove::getCPtable(CPs = CP.188, modelset = 'UCVM', iterate = TRUE)
dim(cp_table_i)
# 12, 9

# Estimate phases 
# 3.2.4 IV
phase_list <- smoove::estimatePhases(cp_table_i)
length(phase_list)
# 13


# using slightly modified plotting function from KB
w_plotPhaseList(phase_list, parameters = c('eta', 'tau'))

# Try to visually understand the results ---

# zoom in on different phases
w_plotPhaseList(
  travelpaths:::subset_phase_list(phase_list, 2, 3),
  parameters = c('eta', 'tau')
)

# Look for patterns in eta vs tau
tau <- sapply(phase_list, function(x) x$estimates$tau[1])
eta <- sapply(phase_list, function(x) x$estimates$eta[1])

plot(eta, tau, col = gplots::rich.colors(length(phase_list)), cex =12, pch=16)

