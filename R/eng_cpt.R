
# Extract the meta data from the fit object.
# For cpt it is not clear what useful meta data would be.
.cpt_change_point_permtest_meta <- function(x) {
  NULL
}

.cpt_change_point_permtest <- function(
  data,
  alpha = 0.05,
  q = 4,
  n = 10000,
  min_move_dist = 0,
  clu = NULL,
  seed = NULL,
  output_col = "cp_id",
  ...
) {
  fitted <- cpt::change_point_test(
    data = data,
    alpha = alpha,
    q = q,
    n = n,
    min_move_dist = min_move_dist,
    clu = clu,
    seed = seed,
    ...
  )
  # By default change_point_test returns a cp_id col
  colnames(fitted) <- swap(colnames(fitted), cp_id = output_col)
  list(
    fit = fitted,
    preproc = list(),
    meta = list(
      n_segments = sum(unique(fitted[[output_col]]) > 0, na.rm = TRUE)
    )
  )
}


.cpt_change_point_permtest_mapping <- function() {
  c("n_permutations" = "n")
}
