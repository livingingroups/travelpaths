# load packages
library(travelpaths)

# set wd as path folder
setwd("~/travelpaths-devel/pkgs/travelpaths/devel")

# load data
FFT <- read.csv(file.path("..", "..", "..", "data", "FFT.csv"))

# travelpaths:::as.track_frame.data.frame
FFT$timestamp <- as.POSIXct(FFT$timestamp)
FFT_tf <- as.track_frame(FFT,
                         index = "timestamp",
                         lon_col = "location.long", #"utm.easting",
                         lat_col = "location.lat", #"utm.northing",
                         id_col = c("individual.local.identifier", "tag.local.identifier") # id_col = "individual.local.identifier"
)

FFT_tf_abby <- dplyr::filter(FFT_tf, individual.local.identifier == "Abby", tag.local.identifier == 4652)
tf <- FFT_tf_abby

library(leaflet)
circles <- data.frame(lng = longitude(tf),
                      lat = latitude(tf),
                      index = as.POSIXct(index(tf)))

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(data = circles[, c("lng", "lat")],
                   color = "red",
                   opacity = 0.25,
                   # fillColor = "blue",
                   # fillOpacity = 0.05,
                   radius = 1) 



library(viridis)
col_pal <- viridis(n=nrow(circles))

leaflet() %>%
  addTiles() %>%
  addCircleMarkers(data = circles[, c("lng", "lat")],
                   color = col_pal,
                   opacity = 0.1,
                   # fillColor = "blue",
                   # fillOpacity = 0.05,
                   radius = 1)




circles1d <- circles[format(circles$index, "%Y-%m-%d") == "2015-12-16",]
circles1d$index2 <- (as.integer(circles1d$index) - min(as.integer(circles1d$index))) / max(as.integer(circles1d$index) - min(as.integer(circles1d$index)))

# col_pal <- viridis(n=nrow(circles1d))
pal <- colorNumeric("viridis", circles1d$index2, reverse = TRUE)

# install.packages("leaflet.extras2")
library(leaflet.extras2)
# addArrowhead
leaflet(circles1d) %>%
  addTiles() %>%
  addCircleMarkers(~lng, ~lat, color = ~pal(index2), group = "circles",
                   opacity = 1,#0.5,
                   fillColor = ~pal(index2),
                   fillOpacity = 1,#0.2,
                   radius = 5) %>%
  addLegend(pal = pal, values = ~index2, group = "circles", position = "bottomleft") %>%
  addArrowhead(lng = ~lng, lat = ~lat, weight = 1,
               options = arrowheadOptions(size = "30%"))



circles1d <- circles[format(circles$index, "%Y-%m-%d") == "2015-12-17",]
circles1d$index2 <- (as.integer(circles1d$index) - min(as.integer(circles1d$index))) / max(as.integer(circles1d$index) - min(as.integer(circles1d$index)))
leaflet(circles1d) %>%
  addTiles() %>%
  addCircleMarkers(~lng, ~lat, color = ~pal(index2), group = "circles",
                   opacity = 1,#0.5,
                   fillColor = ~pal(index2),
                   fillOpacity = 1,#0.2,
                   radius = 5) %>%
  addLegend(pal = pal, values = ~index2, group = "circles", position = "bottomleft") %>%
  addArrowhead(lng = ~lng, lat = ~lat, weight = 1,
               options = arrowheadOptions(size = "30%"))



# timeslider

#load sf data
tf_sf <- tf_to_sf(tf)

tf_sf$day <- as.Date(format(tf_sf$timestamp, "%Y-%m-%d"))
class(tf_sf$timestamp)
pal <- colorNumeric("viridis", tf_sf$day, reverse = TRUE)
leaflet() %>%
  addTiles() %>%
  addTimeslider(
    data = tf_sf,
    color = ~pal(day), #group = "circles",
    opacity = 1,#0.5,
    fillColor = ~pal(day),
    fillOpacity = 1,#0.2,
    radius = 1,
    options = timesliderOptions(
      position = "topright",
      timeAttribute = "timestamp",
      alwaysShowDate = TRUE,
      range = TRUE
    )
  )

tf_sf2 <- tf_sf[format(tf_sf$timestamp, "%Y-%m") == "2015-12" , ]
pal <- colorNumeric("viridis", tf_sf2$day, reverse = TRUE)
leaflet() %>%
  addTiles() %>%
  addTimeslider(
    data = tf_sf2,
    color = ~pal(day), #group = "circles",
    opacity = 1,#0.5,
    fillColor = ~pal(day),
    fillOpacity = 1,#0.2,
    radius = 1,
    options = timesliderOptions(
      position = "topright",
      timeAttribute = "timestamp",
      alwaysShowDate = TRUE,
      range = TRUE
    )
  )

tf_sf2 <- tf_sf[format(tf_sf$timestamp, "%Y-%m") == "2016-01" , ]
pal <- colorNumeric("viridis", tf_sf2$day, reverse = TRUE)
leaflet() %>%
  addTiles() %>%
  addTimeslider(
    data = tf_sf2,
    color = ~pal(day), #group = "circles",
    opacity = 1,#0.5,
    fillColor = ~pal(day),
    fillOpacity = 1,#0.2,
    radius = 1,
    options = timesliderOptions(
      position = "topright",
      timeAttribute = "timestamp",
      alwaysShowDate = TRUE,
      range = TRUE
    )
  )
