# Travelpath Fit

Constructor for the fit `"travelpath_fit"` object.

## Usage

``` r
new_travelpath_fit(spec, fit, elapsed = NULL, preproc = list(), meta = NULL)
```

## Arguments

- spec:

  an object of class `"travelpath_spec"`, giving the original
  specification storing the options used to fit.

- fit:

  the engine output, stored as-is.

- elapsed:

  an object of class `"proc_time"` (as returned by
  [`proc.time`](https://rdrr.io/r/base/proc.time.html)) giving how long
  the fit took.

- preproc:

  a list of preprocessing artifacts, currently a placeholder (empty
  list) reserved for future predict data transformations.

- meta:

  an optional list for storing additional information.

## Value

an object of class `c("<engine>_fit", "<mode>_fit", "travelpath_fit")`,
where `<mode>` is either `"segmentation"` or `"grouping"` taken from
`spec[["mode"]]`.
