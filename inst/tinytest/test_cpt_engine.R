suppressPackageStartupMessages({
  library("tinytest")
  library("checkmate")
  library("trackframe")
  library("travelpaths")
})

if (!isTRUE(requireNamespace("cpt", quietly = TRUE))) {
  exit_file("Could not find package 'cpt'!")
}

#
# Compare API Results
#
data("cpttestdata", package = "cpt")
dat <- as.trackframe(cpttestdata, crs = NA)

# cpt
cpt_fit <- cpt::change_point_test(dat, alpha = 0.05, q = 3, N = 500, seed = 1L)
cpt_fit$cp_id

# travelpaths
cpt_spec <- change_point_permtest(alpha = 0.05)
tp_fit <- fit(cpt_spec, dat, q = 3, N = 500, seed = 1L)
expect_equal(tp_fit$fit$cp_id, cpt_fit$cp_id)


#
# Test accessors
#
expect_equal(specification(tp_fit), cpt_spec)
expect_equal(n_segments(tp_fit), 2)
expect_numeric(elapsed(tp_fit))
expect_equal(segment_col(tp_fit), "cp_id")
# cpt stores no meta data
expect_equal(segment_meta(tp_fit), NULL)

# Attach the cp_id column back onto the trackframe.
tf <- augment(tp_fit, dat)
expect_choice("cp_id", colnames(tf))

# Use it multiple times
tf <- augment(tp_fit, dat, output_col = "cp_id_1")
tf <- augment(tp_fit, tf, output_col = "cp_id_2")
tf <- augment(tp_fit, tf, output_col = "cp_id_3")
expect_true(all(sprintf("cp_id_%i", 1:3) %in% colnames(tf)))

# Arguments from spec shows all the arguments of the fit function
expect_class(arguments(cpt_spec), "function_arguments")
