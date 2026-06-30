# Plot Phases

Plot Phases

## Usage

``` r
plot_phases(
  x,
  cols = NULL,
  plot.parameters = TRUE,
  parameters = NULL,
  plot_legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
)
```

## Arguments

- x:

  an object of class trackframe containing a cvm phases object in the
  attributes or a phase list

- cols:

  colors for phases (by default uses the \`rich.colors\` palette from
  \`gplots\`)

- plot.parameters:

  whether the parameters are plotted

- parameters:

  which parameters to plot (by default - ALL of the estimated
  parameters)

- plot_legend:

  whether to plot a legend

- legend_where:

  location of legend

- layout:

  "horizontal" (default) or "vertical" - as preferred (partial string
  matching accepted)
