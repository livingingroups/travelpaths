#' Plot Phase Parameters
#'
#' Visualizes a specified phase parameter within a phase list, including parameter ranges and
#' values. Supports color-coded shading and labeling.
#'
#' @param variable A character string specifying the name of the parameter to plot
#' (e.g., `"tau"`, `"eta"`).
#' @param phaselist A list of phase data containing attributes required for plotting
#' (e.g., `start`, `end`, `low`, `high`, `hat`).
#' @param cols A vector of colors used for shading and lines, corresponding to the phases.
#' Defaults to `1:length(phaselist)`.
#' @param label Logical. If `TRUE`, adds the parameter name as a label at the top of the plot.
#' Defaults to `TRUE`.
#' @param ... Additional graphical parameters to pass to the `plot` function.
#'
#' @return Produces a plot of the specified phase parameter, including shaded areas for ranges and
#' lines for parameter values.
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' w_plot_phase_parameter("tau", your_phase_list, label = TRUE)
#' }
#' @export
w_plot_phase_parameter <- function(
  variable,
  phaselist,
  cols = seq_along(phaselist),
  label = TRUE,
  ...
) {
  variabletable <- smoove::getPhaseParameter(variable, phaselist)
  low_plot <- variabletable$low #nolint
  high_plot <- variabletable$high #nolint
  with(variabletable, {
    # Remove Infinite values
    plot(
      range(start, end),
      range(low_plot, high_plot[high_plot != Inf], na.rm = TRUE),
      type = "n",
      ...
    )
    if (!is.na(low[1])) {
      rect(start, low_plot, end, high_plot, col = scales::alpha(cols, 0.5), bor = NA)
    }
    segments(start, hat, end, hat, lwd = 2, col = cols)
    segments(end[-length(end)], hat[-length(end)], start[-1], hat[-1], col = "grey")
    if (label) {
      mtext(variable, side = 3, at = start[1], font = 3, adj = 0, cex = 0.8)
    }
  })
}


#' Plot Phases and Associated Parameters
#'
#' This function visualizes phase data contained within a list, along with optional parameter
#' plots, color-coded by phase. It supports customizable legends and layouts.
#'
#' @param phaselist A list containing phase data with attributes `Z` (complex numbers for
#' positions), `time` (timestamps), and phase information.
#' @param cols A vector of colors for each phase. Defaults to
#' `gplots::rich.colors(length(phaselist))`.
#' @param plot.parameters Logical. If `TRUE`, plots associated phase parameters. Defaults to
#' `TRUE`.
#' @param parameters A character vector specifying which parameters to plot (e.g.,
#' `c("eta", "tau")`). If `NULL`, defaults to commonly used parameters found in the phase table.
#' @param plot.legend Logical. If `TRUE`, displays a legend for phase names and models. Defaults
#' to `TRUE`.
#' @param legend_where Position of the legend. Options include `"bottomright"`, `"topleft"`, etc.
#' Defaults to `"bottomright"`.
#' @param layout Layout of parameter plots. Either `"horizontal"` or `"vertical"`. Defaults to
#' `"horizontal"`.
#'
#' @return Generates visual plots of phases and associated parameters.
#' @examples
#' \dontrun{
#' # Example usage:
#' phaselist <- your_phase_data # Replace with actual phase data
#' w_plot_phase_list(phaselist)
#' }
#'
#' @export
w_plot_phase_list <- function(
  phaselist,
  cols = gplots::rich.colors(length(phaselist)),
  plot.parameters = TRUE,
  parameters = NULL,
  plot.legend = TRUE,
  legend_where = "bottomright",
  layout = c("horizontal", "vertical")
) {
  # Added >
  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE, after = FALSE)
  # <

  z <- attr(phaselist, "Z")
  time <- attr(phaselist, "time")
  phase_table <- smoove::summarizePhases(phaselist)
  if (is.null(parameters)) {
    allparameters <- c("eta", "tau", "rms", "mu.x", "mu.y", "omega.x", "omega.y")
    parameters <- names(phase_table)[
      names(phase_table) %in%
        allparameters
    ]
  }
  mars <- par()$mar
  omas <- par()$oma
  omas[1] <- 2
  n_param <- length(parameters)
  if (plot.parameters) {
    if (grepl(layout[1], "vertical")) {
      layout(1:(n_param + 1), heights = c(1, rep(1 / n_param, n_param)))
      par(mar = c(1, mars[2], 2, mars[4]), oma = omas)
    } else {
      par(mar = c(0, mars[2], 2, mars[4]), oma = omas)
      layout(cbind(rep(1, n_param), 1:n_param + 1))
    }
  }
  t_cuts <- c(phase_table$start, max(time))
  z_cols <- cols[cut(time, t_cuts, include.lowest = TRUE)]
  plot(z, asp = 1, type = "l", xpd = FALSE, xlab = "X", ylab = "Y")
  points(z, col = z_cols, pch = 21, bg = scales::alpha(z_cols, 0.5), cex = 0.8)
  if (plot.legend) {
    legend(
      legend_where,
      legend = paste0(phase_table$phase, ": ", phase_table$model),
      fill = cols,
      ncol = 3,
      bty = "n",
      title = "Phase: model"
    )
  }
  if (plot.parameters) {
    mars <- par()$mar
    par(mar = c(0, mars[2], 1.5, mars[4]))
    for (p in parameters) {
      w_plot_phase_parameter(
        p,
        phaselist,
        ylab = "",
        xlab = "",
        cols = cols,
        xaxt = ifelse(p == parameters[length(parameters)], "s", "n")
        # Removed: log scale for tau
        #,log = ifelse(p == "tau", "y", "")
      )
    }
  }
}

#' Subset a Phase List
#'
#' Extracts a subset of a phase list based on the specified range and adjusts related attributes
#' (time, time unit, and Z values) accordingly.
#'
#' @param phase_list A list containing phases, including attributes `time.unit`, `time`, and `Z`.
#' @param from Integer. The starting index for subsetting the phase list. Defaults to `1`.
#' @param to Integer. The ending index for subsetting the phase list. Defaults to
#' `length(phase_list)`.
#'
#' @return A subset of the phase list, with adjusted attributes:
#' \itemize{
#'   \item \code{time.unit}: Preserved from the original phase list.
#'   \item \code{time}: Adjusted to match the subset time range.
#'   \item \code{Z}: Adjusted to match the subset time range.
#' }
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' subset_phase_list(your_phase_list, from = 2, to = 5)
#' }
subset_phase_list <- function(phase_list, from = 1, to = length(phase_list)) {
  spl <- phase_list[from:to]
  start <- spl[[1]][["start"]]
  end <- spl[[length(spl)]][["end"]]
  attr(spl, "time.unit") <- attr(phase_list, "time.unit")
  ind_spl <- which(attr(phase_list, "time") >= start & attr(phase_list, "time") <= end)
  attr(spl, "time") <- attr(phase_list, "time")[ind_spl] #[start:end]
  attr(spl, "Z") <- attr(phase_list, "Z")[ind_spl] #[start:end]
  spl
}
