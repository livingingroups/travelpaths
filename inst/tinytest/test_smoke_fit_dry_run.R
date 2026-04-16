library("travelpaths")
data("tf_mini", package="trackframe")


dry_run_fit <- function(spec, ...) {
  as.list(fit(spec, tf_mini, dry_run = TRUE, ...))
}


if (!requireNamespace("infostop", quietly = TRUE)) {
  exit_file("infostop not installed - skipping infostop dry-run tests")
}

# ============================================================================
# threshold_stops / infostop::identify_stops
# ============================================================================

ths_call <- dry_run_fit(threshold_stops())
expect_true(is.function(ths_call[[1]]))
# [[2]] must be the data object passed to fit()
expect_identical(ths_call[[2]], tf_mini)
ths_formals <- formals(threshold_stops)

for (key in intersect(names(ths_call), names(ths_formals))) {
  expect_equal(ths_call[[key]], ths_formals[[key]])
}

# dry_run must not leak into the call list
expect_true(is.null(ths_call[["dry_run"]]))

ths_custom_call <- dry_run_fit(threshold_stops(r1 = 50, min_size = 5L))
expect_equal(ths_custom_call[["r1"]], 50)
expect_equal(ths_custom_call[["min_size"]], 5L)
expect_equal(ths_custom_call[["min_staying_time"]], 300L)


# --- update() + dry run ---
ths_updated_call <- dry_run_fit(update(threshold_stops(r1 = 10), r1 = 99))
expect_equal(ths_updated_call[["r1"]], 99)
expect_equal(ths_updated_call[["min_size"]], 2L)
