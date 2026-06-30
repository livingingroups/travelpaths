# Plot Phases and Associated Parameters

This function visualizes phase data contained within a list, along with
optional parameter plots, color-coded by phase. It supports customizable
legends and layouts.

## Usage

``` r
w_plot_phase_list(
  phaselist,
  cols = gplots::rich.colors(length(phaselist)),
  plot.parameters = TRUE,
  parameters = NULL,
  plot.legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
)
```

## Arguments

- phaselist:

  A list containing phase data with attributes \`Z\` (complex numbers
  for positions), \`time\` (timestamps), and phase information.

- cols:

  A vector of colors for each phase. Defaults to
  \`gplots::rich.colors(length(phaselist))\`.

- plot.parameters:

  Logical. If \`TRUE\`, plots associated phase parameters. Defaults to
  \`TRUE\`.

- parameters:

  A character vector specifying which parameters to plot (e.g.,
  \`c("eta", "tau")\`). If \`NULL\`, defaults to commonly used
  parameters found in the phase table.

- plot.legend:

  Logical. If \`TRUE\`, displays a legend for phase names and models.
  Defaults to \`TRUE\`.

- legend_where:

  Position of the legend. Options include \`"bottomright"\`,
  \`"topleft"\`, etc. Defaults to \`"bottomright"\`.

- layout:

  Layout of parameter plots. Either \`"horizontal"\` or \`"vertical"\`.
  Defaults to \`"horizontal"\`.

## Value

Generates visual plots of phases and associated parameters.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
phaselist <- your_phase_data # Replace with actual phase data
w_plot_phase_list(phaselist)
} # }
```
