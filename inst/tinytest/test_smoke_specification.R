library("travelpaths")


# Test init and data storage
spec <- new_travelpath_spec(
  "my_spec", list(a = 1), list(b = 2), "segmentation", "infostop"
)
expect_inherits(spec, "my_spec")
expect_inherits(spec, "travelpath_spec")
expect_equal(class(spec), c("my_spec", "travelpath_spec"))

expect_identical(spec$args, list(a = 1))
expect_identical(spec$eng_args, list(b = 2))

expect_equal(spec$mode, "segmentation")
expect_equal(spec$engine, "infostop")


# Test input validation
valid_input <- list("my_spec", list(a = 1), list(b = 2), "segmentation", "infostop")
for (i in seq_along(valid_input)) {
  invalid_input <- valid_input
  invalid_input[[i]] <- NULL
  expect_error(do.call(new_travelpath_spec, invalid_input))
}


# Test threshold_stops
ths <- threshold_stops()
expect_inherits(ths, "threshold_stops")
expect_inherits(ths, "travelpath_spec")
expect_equal(ths$mode, "segmentation")
expect_equal(ths$engine, "infostop")
expect_null(ths$method)

expect_equal(ths$args$r1, 10)
expect_equal(ths$args$min_size, 2L)
expect_equal(ths$args$min_staying_time, 300L)
expect_equal(ths$args$max_time_between, 86400L)
expect_equal(ths$args$stop_id_col, "stop_id")

ths_custom <- threshold_stops(r1 = 25, min_size = 5L)
expect_equal(ths_custom$args$r1, 25)
expect_equal(ths_custom$args$min_size, 5L)
expect_equal(ths_custom$args$min_staying_time, 300L)


# Test update
base_spec <- threshold_stops(r1 = 10, min_size = 2L)

updated <- update(base_spec, params = list(r1 = 50))
expect_equal(updated$args$r1, 50)
expect_equal(updated$args$min_size, 2L)

# update via dots changes targeted arg
updated_dots <- update(base_spec, r1 = 99)
expect_equal(updated_dots$args$r1, 99)
expect_equal(updated_dots$args$min_size, 2L)

# params and dots can be combined
updated_both <- update(base_spec, params = list(r1 = 30), min_size = 7L)
expect_equal(updated_both$args$r1, 30)
expect_equal(updated_both$args$min_size, 7L)

# fresh = FALSE (default) preserves existing values for unspecified args
not_fresh <- update(base_spec, params = list(r1 = 77), fresh = FALSE)
expect_equal(not_fresh$args$r1, 77)
expect_equal(not_fresh$args$min_size, 2L)

# fresh = TRUE resets unspecified args to constructor defaults
modified_spec <- threshold_stops(r1 = 77, min_size = 9L)
fresh_spec <- update(modified_spec, fresh = TRUE, r1 = 1)
expect_equal(fresh_spec$args$r1, 1)
expect_equal(fresh_spec$args$min_size, 2L)       # reset to default
expect_equal(fresh_spec$args$min_staying_time, 300L) # reset to default
