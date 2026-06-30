.onLoad <- function(libname, pkgname) {
  # NOTE: For cpt we are more explicit since there exists a second cpt package.
  if (is_pkg_installed("cpt", "change_point_test")) {
    register_fit_function(
      "change_point_permtest",
      "segmentation",
      "cpt",
      .cpt_change_point_permtest
    )
    register_argument_mapping(
      "change_point_permtest",
      "segmentation",
      "cpt",
      .cpt_change_point_permtest_mapping()
    )
  }

  if (is_pkg_installed("infostop")) {
    register_fit_function(
      "threshold_stops",
      "segmentation",
      "infostop",
      .infostop_identify_stops
    )
    register_fit_function(
      "infomap",
      "grouping",
      "infostop",
      .infostop_identify_sites
    )
  }

  if (is_pkg_installed("smoove")) {
    register_fit_function(
      "cvm_change_points",
      "segmentation",
      "smoove",
      cvm_segment
    )
  }
}


.onAttach <- function(libname, pkgname) {
  packageStartupMessage("travelpaths: A framework for travel path analysis in R.")
  rff <- registered_fit_functions()
  if (nrow(rff) == 0L) {
    return(invisible(NULL))
  }
  rff <- rff[order(rff$mode, rff$engine, rff$model), c("mode", "engine", "model")]
  rows <- sprintf("    %-25s %-15s %s", rff$model, rff$mode, rff$engine)
  msg <- paste(
    c(sprintf("    %-25s %-15s %s", "Model", "Mode", "Engine"), rows),
    collapse = "\n"
  )
  packageStartupMessage("Registered models:\n", msg)
}
