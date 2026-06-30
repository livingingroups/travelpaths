
# FIXME: We can delete this before the upload but now it allows to filter out
#        long runnning tasks during development.
dev_run_tests <- function() {
  t0 <- Sys.time()
  file_names <- dir("inst/tinytest", full.names = TRUE)
  # exclude long running tests
  exclude <- c("smoove")
  file_names <- grep(pattern = exclude, file_names, value = TRUE, invert = TRUE)
  test_output <- lapply(file_names, tinytest::run_test_file)
  td <- abs(as.numeric(Sys.time()) - as.numeric(t0))
  structure(
    unlist(test_output, recursive = FALSE),
    class = "tinytests",
    duration = td
  )
}
