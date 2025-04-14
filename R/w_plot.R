#' @export
w_plotPhaseParameter <- function (variable, phaselist, cols = 1:length(phaselist), label = TRUE, 
                                  ...) 
{
  variabletable <- smoove::getPhaseParameter(variable, phaselist)
  low.plot <- variabletable$low
  high.plot <- variabletable$high
  with(variabletable, {
    # Remove Infinite values
    plot(range(start, end), range(low.plot, high.plot[high.plot!=Inf], na.rm = TRUE), 
         type = "n", ...)
    if (!is.na(low[1])) 
      rect(start, low.plot, end, high.plot, col = scales::alpha(cols, 
                                                                0.5), bor = NA)
    segments(start, hat, end, hat, lwd = 2, col = cols)
    segments(end[-length(end)], hat[-length(end)], start[-1], 
             hat[-1], col = "grey")
    if (label) 
      mtext(variable, side = 3, at = start[1], font = 3, 
            adj = 0, cex = 0.8)
  })
}

#' @export
w_plotPhaseList <- function(phaselist, cols = gplots::rich.colors(length(phaselist)), 
                            plot.parameters = TRUE, parameters = NULL, plot.legend = TRUE,
                            legend.where = "bottomright", layout = c("horizontal", "vertical"))
{
  
  # Added > 
  op <- par(no.readonly = TRUE)
  on.exit(par(op), add = TRUE, after = FALSE)
  # <
  
  Z <- attr(phaselist, "Z")
  time <- attr(phaselist, "time")
  phaseTable <- smoove::summarizePhases(phaselist)
  if (is.null(parameters)) {
    allparameters <- c("eta", "tau", "rms", "mu.x", "mu.y", 
                       "omega.x", "omega.y")
    parameters <- names(phaseTable)[names(phaseTable) %in% 
                                      allparameters]
  }
  mars <- par()$mar
  omas <- par()$oma
  omas[1] <- 2
  n.param <- length(parameters)
  if (plot.parameters) {
    if (grepl(layout[1], "vertical")) {
      layout(1:(n.param + 1), heights = c(1, rep(1/n.param, 
                                                 n.param)))
      par(mar = c(1, mars[2], 2, mars[4]), oma = omas)
    }
    else {
      par(mar = c(0, mars[2], 2, mars[4]), oma = omas)
      layout(cbind(rep(1, n.param), 1:n.param + 1))
    }
  }
  T.cuts <- c(phaseTable$start, max(time))
  Z.cols <- cols[cut(time, T.cuts, include.lowest = TRUE)]
  plot(Z, asp = 1, type = "l", xpd = FALSE, xlab = "X", ylab = "Y")
  points(Z, col = Z.cols, pch = 21, bg = scales::alpha(Z.cols, 0.5), 
         cex = 0.8)
  if (plot.legend) {
    legend(legend.where, legend = paste0(phaseTable$phase, 
                                         ": ", phaseTable$model), fill = cols, ncol = 3, bty = "n", 
           title = "Phase: model")
  }
  if (plot.parameters) {
    mars <- par()$mar
    par(mar = c(0, mars[2], 1.5, mars[4]))
    for (p in parameters) w_plotPhaseParameter(p, phaselist, 
                                               ylab = "", xlab = "", col = cols,
                                               xaxt = ifelse(p == 
                                                               parameters[length(parameters)], "s", "n")
                                               # Removed: log scale for tau
                                               #,log = ifelse(p == "tau", "y", "")
    )
  }
}

#' @export
subset_phase_list <- function(phase_list, from = 1, to = length(phase_list)){
  spl <- phase_list[from:to]
  start <- spl[[1]][['start']]
  end <- spl[[length(spl)]][['end']]
  attr(spl, 'time.unit') <- attr(phase_list, 'time.unit')
  ind_spl <- which(attr(phase_list, 'time') >= start &  attr(phase_list, 'time') <= end)
  attr(spl, 'time') <- attr(phase_list, 'time')[ind_spl] #[start:end]
  attr(spl, 'Z') <- attr(phase_list, 'Z')[ind_spl] #[start:end]
  spl
}
