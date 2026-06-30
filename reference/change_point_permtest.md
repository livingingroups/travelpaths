# Change Point Permutation Test Specification

Constructs a travelpath specification for change point detection using a
permutation test. This function creates a specification object for
change point analysis using the \`cpt::change_point_test\` engine. The
method detects change points in a sequence by comparing segments using a
specified distance metric and assessing significance via permutation
testing.

## Usage

``` r
change_point_permtest(
  mode = "segmentation",
  engine = "cpt",
  alpha = 0.05,
  output_col = "cp_id"
)
```

## Arguments

- mode:

  The analysis mode. Only "segmentation" is supported.

- engine:

  The computational engine to use. Default is "cpt".

- alpha:

  Significance level for the permutation test (default: 0.05).

- output_col:

  Name of the output column added to the trackframe (default:
  `"cp_id"`).

## Value

A travelpath specification object for change point detection.

## Details

This specification uses the \`cpt::change_point_test\` function to
perform change point detection via permutation testing.

## See also

\[cpt::change_point_test()\]

## Examples

``` r
spec <- change_point_permtest(alpha = 0.01)
```
