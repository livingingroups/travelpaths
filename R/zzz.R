

.onLoad <- function(libname, pkgname) { 
  # NOTE: For cpt we more explicit since the exists a second cpt package.
  if (is_pkg_installed("cpt", "change_point_test")) {
    register_fit_function("change_point_permtest", "segmentation", "cpt", cpt::change_point_test)
    register_argument_mapping("change_point_permtest", "segmentation", "cpt", c("n_permutations" = "n"))
  }

  if (is_pkg_installed("infostop")) {
    register_fit_function("threshold_stops", "segmentation", "infostop", infostop::identify_stops)
    register_fit_function("infomap", "grouping", "infostop", infostop::identify_sites)
  }

  if (is_pkg_installed("smoove")) {
    register_fit_function(
      "cvm_change_points",
      "segmentation",
      "smoove",
      cvm_estimate_change_points
    )
    register_fit_function("cvm_phases", "grouping", "smoove", cvm_estimate_phases)
  }
}


.onAttach <- function(libname, pkgname) {
  packageStartupMessage("travelpaths: A framework for travel path analysis in R.")
  rff <- registered_fit_functions()
  if (nrow(rff) == 0L) return(invisible(NULL))
  rff <- rff[order(rff$mode, rff$engine, rff$model), c("mode", "engine", "model")]
  rows <- sprintf("    %-25s %-15s %s", rff$model, rff$mode, rff$engine)
  msg <- paste(
    c(sprintf("    %-25s %-15s %s", "Model", "Mode", "Engine"), rows),
    collapse = "\n"
  )
  packageStartupMessage("Registered models:\n", msg)
}
