# Extract Fit

The raw engine object of a given `"travelpath_fit"` can be accessed via
the method `'fitted'`. The returned object is whatever the engine
produced, it is stored verbatim and is not mutated by travelpaths. For
the built-in engines this is typically a trackframe with an extra
column.

## Usage

``` r
# S3 method for class 'travelpath_fit'
fitted(object, ...)
```

## Arguments

- object:

  object from which the fit is extracted.

- ...:

  further arguments currently ignored.

## Value

the raw engine object as returned by the engine.
