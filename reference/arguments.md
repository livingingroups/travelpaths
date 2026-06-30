# Extract arguments from an object

This method extracts the formal arguments of an object. For objects of
\`travelpath_spec\` extracts the formal arguments of the fitting
function associated with a travelpath specification object.

## Usage

``` r
arguments(x, ...)
```

## Arguments

- x:

  an object.

- ...:

  additional arguments (currently unused).

## Value

A pairlist of formal arguments from the associated function, as returned
by \`formals()\`.

## Examples

``` r
spec <- threshold_stops()
arguments(spec)
#> Function with 7 arguments:
#>  $ data            : symbol 
#>  $ r1              : num 10
#>  $ min_size        : int 2
#>  $ min_staying_time: int 300
#>  $ max_time_between: int 86400
#>  $ output_col      : chr "stop_id"
#>  $ ...             : symbol 
```
