# install
# infostop:::conda_install_infostop() #FIXME


# # load packages
# python_exe <- normalizePath("~/.conda/envs/infostop/bin/python")
# Sys.setenv(RETICULATE_PYTHON = python_exe)
# Sys.setenv(INFOSTOP_PYTHON = python_exe)

library("infostop")
library("trackframe")

infostop_initialize()

# set wd as path folder
setwd("~/travelpaths-devel/pkgs/travelpaths/devel")

# load data
FFT <- read.csv(file.path("..", "..", "..", "data", "FFT.csv"))

FFT$timestamp <- as.POSIXct(FFT$timestamp)
FFT_tf_lon_lat <- as.track_frame(FFT,
                         time_col  = "timestamp",
                         easting_col = "location.lat", #"utm.easting",
                         northing_col = "location.long",#"utm.northing",
                         id_col = "individual.local.identifier"
)

FFT_tf <- as.track_frame(FFT,
                         time_col  = "timestamp",
                         easting_col = "utm.easting", #"utm.easting",
                         northing_col = "utm.northing",#"utm.northing",
                         id_col = "individual.local.identifier"
)
class(FFT_tf$timestamp)

# FFT_tf_abby <- select_id(tf = FFT_tf, id = "Abby")
FFT_tf_abby <- dplyr::filter(FFT_tf, individual.local.identifier == "Abby", tag.local.identifier == 4652)
FFT_tf_abby_lon_lat <- dplyr::filter(FFT_tf_lon_lat, individual.local.identifier == "Abby", tag.local.identifier == 4652)
# FFT_tf_abby <- select_id(tf = FFT_tf, id = c("Abby", "4652"))
dim(FFT_tf_abby)

tf <- FFT_tf_abby
tf_lon_lat <- FFT_tf_abby_lon_lat

# onestep
mod_lon_lat <- infostop(tf_lon_lat, distance_metric = "haversine")
mod <- infostop(tf, distance_metric = "euclidean")
mod

# twostep
stops <- find_stops(tf_lon_lat, r1 = 10, min_staying_time = 300L, max_time_between = 86400L, distance_metric = "haversine")
twostep <- spatial_infomap(stops[['coordinates']], r2 = 10, distance_metric = "haversine")

stops <- find_stops(tf, r1 = 10, min_staying_time = 300L, max_time_between = 86400L, distance_metric = "euclidean")
twostep <- spatial_infomap(stops[['coordinates']], r2 = 10, distance_metric = "euclidean")

mod$compute_label_medians()


stops$compute_label_medians()

# map <- plot_map(mod)
map <- plot_map(mod,  # only available for distance "haversine" (lonlat)
                scatter = TRUE, 
                polygons_color = "#ff0000", 
                zoom_start = 15)

map <- plot_map(mod_lon_lat, 
                scatter = TRUE, 
                polygons_color = "#ff0000", 
                zoom_start = 15)

## Not run: 
# map$show_in_browser()
map$save("map_lon_lat.html")


#TODO write accessor functions
py_dir <- reticulate::py_eval("dir", FALSE)
reticulate::py_to_r(py_dir(mod$model))

# number of raw points
dim(tf)[1]
# 15729


# dim(mod$`_stat_coords`)[1]
dim(mod$model$`_stat_coords`)[1]
# 1268

# number of stop locations
labels <- mod$labels
length(unique(labels)) - 1
# 179

dim(mod$model$`_stat_labels`)[1]

cbind(labels, do.call(rbind, mod$model$`_data`))

mod$compute_label_medians()

labels

print(mod)

mod$model$`_stat_coords`


mod

attributes(tf_lon_lat)
simod <- spatial_infomap(tf_lon_lat, distance_metric = "haversine")
simod <- spatial_infomap(tf, distance_metric = "euclidean")
simod$labels


length(mod$labels)
intervals <- compute_intervals(mod$labels, as.integer(time(tf)))
intervals
