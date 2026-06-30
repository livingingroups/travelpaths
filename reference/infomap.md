# Infomap Site Identification

\`infomap()\` defines a model that identifies sites from movement stops
using the Infomap community detection algorithm. This method clusters
spatially proximate stops into meaningful sites by creating a network of
stops and applying information-theoretic community detection.

There are different ways to fit this model, and the method of estimation
is chosen by setting the model engine. The engine-specific pages for
this model are listed below.

\-
[`infostop::identify_sites`](https://rdrr.io/pkg/infostop/man/identify_sites.html):
Infomap-based site identification

## Usage

``` r
infomap(
  mode = "grouping",
  engine = "infostop",
  r2 = 10,
  label_singleton = TRUE,
  min_spacial_resolution = 0,
  weighted = FALSE,
  weight_exponent = 1,
  stop_id_col = "stop_id",
  output_col = "site_id"
)
```

## Arguments

- mode:

  A character string for the type of model. The only possible value for
  this model is "grouping".

- engine:

  A character string specifying what computational engine to use for
  fitting. Possible engines are listed below. The default for this model
  is \`"infostop"\`.

- r2:

  A positive numeric value giving the maximum distance between
  stationary points to form an edge in the network representation.

- label_singleton:

  A logical value. If TRUE, give stationary locations that were only
  visited once their own label. If FALSE, label them as non-stationary
  (-1).

- min_spacial_resolution:

  A numeric value giving the minimal difference allowed between points
  before they are considered the same points.

- weighted:

  A logical value. If TRUE, weight edges in the network representation
  by distance.

- weight_exponent:

  A positive numeric value giving the exponent used when weighting edges
  in the network.

- stop_id_col:

  A character string specifying the name of the column to be used for
  the stop identifiers. Default is "stop_id".

- output_col:

  A character string specifying the name of the column to be used for
  the site identifiers. Default is "site_id".

## Value

An \`infomap\` specification.

## Examples

``` r
infomap()
#> $args
#> $args$r2
#> [1] 10
#> 
#> $args$label_singleton
#> [1] TRUE
#> 
#> $args$min_spacial_resolution
#> [1] 0
#> 
#> $args$weighted
#> [1] FALSE
#> 
#> $args$weight_exponent
#> [1] 1
#> 
#> $args$stop_id_col
#> [1] "stop_id"
#> 
#> $args$output_col
#> [1] "site_id"
#> 
#> 
#> $eng_args
#> list()
#> 
#> $mode
#> [1] "grouping"
#> 
#> $method
#> NULL
#> 
#> $engine
#> [1] "infostop"
#> 
#> attr(,"class")
#> [1] "infomap"         "travelpath_spec"

infomap(
  r2 = 50,
  weighted = TRUE
)
#> $args
#> $args$r2
#> [1] 50
#> 
#> $args$label_singleton
#> [1] TRUE
#> 
#> $args$min_spacial_resolution
#> [1] 0
#> 
#> $args$weighted
#> [1] TRUE
#> 
#> $args$weight_exponent
#> [1] 1
#> 
#> $args$stop_id_col
#> [1] "stop_id"
#> 
#> $args$output_col
#> [1] "site_id"
#> 
#> 
#> $eng_args
#> list()
#> 
#> $mode
#> [1] "grouping"
#> 
#> $method
#> NULL
#> 
#> $engine
#> [1] "infostop"
#> 
#> attr(,"class")
#> [1] "infomap"         "travelpath_spec"
```
