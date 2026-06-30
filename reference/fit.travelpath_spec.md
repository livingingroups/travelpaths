# Fit a Travelpath Model Specification

\`fit.travelpath_spec()\` is the S3 method for fitting travelpath model
specifications to movement data. This function takes a travelpath
specification object and applies the specified algorithm to the provided
data using the configured engine and parameters.

## Usage

``` r
# S3 method for class 'travelpath_spec'
fit(object, data, ...)
```

## Arguments

- object:

  A travelpath specification object created by functions like
  \`threshold_stops()\` or \`infomap()\`. The object contains the model
  type, mode, engine, and parameter settings.

- data:

  A movement data object (e.g., trackframe, move2, sftrack) containing
  the trajectory data to be analyzed.

- ...:

  Additional arguments passed to the underlying fitting function.

## Value

An object of class \`"travelpath_fit"\`, which is a list containing:

- spec:

  The original specification storing the options used to fit.

- fit:

  The original fit output from the engine, stored as-is.

- preproc:

  A list of preprocessing artifacts (reserved for future use).

- elapsed:

  An object of class `"proc_time"`, as returned by
  [`proc.time`](https://rdrr.io/r/base/proc.time.html)) giving how long
  the fit took.

- meta:

  An optional list for storing additional information.

## Details

This function serves as the main interface for fitting travelpath
models. It performs the following steps:

1\. Validates the specification object. 2. Determines the appropriate
fitting function based on the model, mode, and engine. 3. Calls the
fitting function with the data and specification parameters.

The fitting function is retrieved using the model registry system, which
maps combinations of model types, modes, and engines to their
corresponding implementation functions.

## See also

\[threshold_stops()\], \[infomap()\], \[register_fit_function()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# FIXME: Activate this example based on the example in tinytest.
# Fit a threshold stops model
stops_spec <- threshold_stops(r1 = 20, min_size = 3)
result <- fit(stops_spec, movement_data)

# Fit an infomap sites model
sites_spec <- infomap(r2 = 50, weighted = TRUE)
result <- fit(sites_spec, stops_data)
} # }
```
