

find_test_dir <- function(test_dir, package) {
  if (dir.exists(test_dir)) {
    return(test_dir)
  }
  system.file(basename(test_dir), package = package)
}


if (suppressPackageStartupMessages(requireNamespace("tinytest", quietly = TRUE))) {
  if (identical(Sys.getenv("TINYTEST_SMOKE"), "TRUE")) {
    test_dir <- find_test_dir("inst/tinytest", "travelpaths")
    tinytest::run_test_dir(dir = test_dir, pattern = "test_smoke_.*\\.(r|R)")
  } else {
    tinytest::test_package("travelpaths")
  }
}
