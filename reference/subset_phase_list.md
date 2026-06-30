# Subset a Phase List

Extracts a subset of a phase list based on the specified range and
adjusts related attributes (time, time unit, and Z values) accordingly.

## Usage

``` r
subset_phase_list(phase_list, from = 1, to = length(phase_list))
```

## Arguments

- phase_list:

  A list containing phases, including attributes \`time.unit\`,
  \`time\`, and \`Z\`.

- from:

  Integer. The starting index for subsetting the phase list. Defaults to
  \`1\`.

- to:

  Integer. The ending index for subsetting the phase list. Defaults to
  \`length(phase_list)\`.

## Value

A subset of the phase list, with adjusted attributes:

- `time.unit`: Preserved from the original phase list.

- `time`: Adjusted to match the subset time range.

- `Z`: Adjusted to match the subset time range.

## Examples

``` r
if (FALSE) { # \dontrun{
subset_phase_list(your_phase_list, from = 2, to = 5)
} # }
```
