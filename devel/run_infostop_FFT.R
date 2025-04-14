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
FFT <- read.csv("../../../data/FFT.csv")

FFT$timestamp <- as.POSIXct(FFT$timestamp)
FFT_tf <- as.track_frame(FFT,
                         index = "timestamp",
                         lon_col = "location.long",
                         lat_col = "location.lat",
                         id_col = c("individual.local.identifier", "tag.local.identifier")
)
class(FFT_tf$timestamp)

# FFT_tf_abby <- select_id(tf = FFT_tf, id = "Abby")
FFT_tf_abby <- dplyr::filter(FFT_tf, individual.local.identifier == "Abby", tag.local.identifier == 4652)
# FFT_tf_abby <- select_id(tf = FFT_tf, id = c("Abby", "4652"))
dim(FFT_tf_abby)

tf <- FFT_tf_abby


mod <- infostop(tf)

mod$compute_label_medians()

# map <- plot_map(mod)
map <- plot_map(mod, 
                scatter = TRUE, 
                polygons_color = "#ff0000", 
                zoom_start = 15)

## Not run: 
# map$show_in_browser()
map$save("map.html")


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

simod <- spatial_infomap(tf)
simod$labels

