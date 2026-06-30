# Travel Paths

## Package **travelpaths**

``` r

library("travelpaths")
library("infostop")

data("path_move2", package = "trackframe")
```

The **travelpaths** pipline is devided into 3 steps,

1.  **segment**
2.  **group**
3.  **predict**

### Infostop

#### Segment with `threshold_stops()`

``` r

args(threshold_stops)
```

``` r

ths_spec <- threshold_stops(
  distance_metric = "haversine",
  r1 = 20,
  min_size = 3
)

stops <- fit(ths_spec, path_move2)
head(stops)
```

``` r

args(infomap)
```

#### Group with `infomap()`

``` r

im_spec <- infomap()
sites <- fit(im_spec, stops)
head(sites)
```

### Change point test

#### Detecting change points with `change_point_permtest()`

``` r

args(change_point_permtest)
```

``` r

data("cpttestdata", package = "cpt")
cpt_spec <- change_point_permtest()
```

Inspect the arguments of the change point test specification:

``` r

arguments(cpt_spec)
```

We might should split it into `args` and `eng_args` sections. Also we
have to consider the mapping.

``` r

cpt_spec <- update(cpt_spec, q = 5, n = 10000, seed = 0)
```

``` r

cpt_tf <- fit(cpt_spec, cpttestdata)
head(cpt_tf)
```

### Smoove

``` r

library(smoove)
data(Kestrel)
k <- Kestrel[3730:4150, ]
head(k)
```

``` r

# with(k, scan_track(x=X, y=Y, time = timestamp))
```

``` r

library(trackframe)
data <- as.trackframe(k,
  easting_col = "X",
  northing_col = "Y",
  crs = NA)
```

Inspect the arguments of the change point detection by cvm

``` r

args(cvm_change_points)
```

Specify the model spec

``` r

cpt_spec <- cvm_change_points(
  windowsize = 50,
  windowstep = 5,
  model = "RACVM",
  time_unit = "secs"
)
```

Estimate the change points

``` r

cpt_fit <- fit(cpt_spec, data)
head(cpt_fit)
```

Specify the phases object

``` r

args(cvm_phases)

phases_spec <- cvm_phases()
```

Fit the phases (grouping)

``` r

phases <- fit(phases_spec, cpt_fit)
head(phases)
```
