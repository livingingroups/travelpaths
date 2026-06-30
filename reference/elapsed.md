# Extract Elapsed Time

The timing information of a given `"travelpath_fit"` can be accessed via
the method `'elapsed'`.

## Usage

``` r
elapsed(x, ...)
```

## Arguments

- x:

  object from which the elapsed time is extracted.

- ...:

  further arguments currently ignored.

## Value

an object of class `"proc_time"` as returned by
[`proc.time`](https://rdrr.io/r/base/proc.time.html)
