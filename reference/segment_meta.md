# Metadata from a segmentation / grouping fit

\`segment_meta()\` and \`group_meta()\` return the \`meta\` slot (a
`data.frame` with one row per segment / group, or \`NULL\`) with the
mode-specific dispatch used by the rest of the package.

## Usage

``` r
segment_meta(x, ...)

group_meta(x, ...)
```

## Arguments

- x:

  a `travelpath_fit` object.

- ...:

  additional arguments currently unused.

## Value

A \`data.frame\` with \`n_groups(x)\` rows, or \`NULL\` when the engine
provides no per-label metadata.
