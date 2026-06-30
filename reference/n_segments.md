# Accessor Functions for Segments and Groups

The number of segments or groups produced by a `"travelpath_fit"` can be
accessed via `'n_segments'` and `'n_groups'`. These are mode-specific:
use `n_segments()` for a `"segmentation"` fit, and `n_groups()` for a
`"grouping"` fit.

## Usage

``` r
n_segments(x, ...)

n_groups(x, ...)
```

## Arguments

- x:

  object from which the number of groups or segments are extracted.

- ...:

  further arguments currently ignored.

## Value

an integer vector giving the number of segments or groups for each
track.
