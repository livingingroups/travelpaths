# Smoove

## R Markdown

load Packages

load Kestrel data from R package smoove

``` r

data(Kestrel)
k <- Kestrel[3730:4150, ]
```

``` r

data <- as.trackframe(k,
  easting_col = "X",
  northing_col = "Y",
  crs = NA)
```

Plot data

``` r

plot(data)
```

Plot Coordinates by time

``` r

plot_coords_by_time(data)
```

``` r

args(cvm_change_points)

cpt_spec <- cvm_change_points(
  windowsize = 50,
  windowstep = 5,
  model = "RACVM",
  time_unit = "secs",
  progress = FALSE
)

cpt_fit <- fit(cpt_spec, data)
head(cpt_fit)
class(cpt_fit)

args(cvm_phases)

phases_spec <- cvm_phases()
phases <- fit(phases_spec, cpt_fit)

class(phases)
###
```

Plot coordinates by time with change points

``` r

plot_coords_by_time(data, change_point_id = "cp_id")
```

``` r

plot(x = phases, start_point = TRUE, end_point = TRUE, direction = FALSE,
  change_point_id = "cp_id")
```

``` r

plot_phases(phases)
```

``` r

summarize_phases(phases)
```

or directly phase list stored in attributes

``` r

phase_list <- attr(phases, "cvm_phases")
summarizePhases(phase_list)
plot_phases(phase_list)
summarize_phases(phase_list)
```
