# Plot Phase Parameters

Visualizes a specified phase parameter within a phase list, including
parameter ranges and values. Supports color-coded shading and labeling.

## Usage

``` r
w_plot_phase_parameter(
  variable,
  phaselist,
  cols = seq_along(phaselist),
  label = TRUE,
  ...
)
```

## Arguments

- variable:

  A character string specifying the name of the parameter to plot (e.g.,
  \`"tau"\`, \`"eta"\`).

- phaselist:

  A list of phase data containing attributes required for plotting
  (e.g., \`start\`, \`end\`, \`low\`, \`high\`, \`hat\`).

- cols:

  A vector of colors used for shading and lines, corresponding to the
  phases. Defaults to \`1:length(phaselist)\`.

- label:

  Logical. If \`TRUE\`, adds the parameter name as a label at the top of
  the plot. Defaults to \`TRUE\`.

- ...:

  Additional graphical parameters to pass to the \`plot\` function.

## Value

Produces a plot of the specified phase parameter, including shaded areas
for ranges and lines for parameter values.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
w_plot_phase_parameter("tau", your_phase_list, label = TRUE)
} # }
```
