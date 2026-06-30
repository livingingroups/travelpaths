# Augment a Trackframe with the Fit Output

`augment()` writes the fit's assignment column onto `new_data`.
`new_data` is expected to be the training trackframe (same rows in the
same order as the data originally passed to
[`fit.travelpath_spec`](fit.travelpath_spec.md)).

## Arguments

- x:

  an object of class `"travelpath_fit"`.

- new_data:

  a trackframe, normally the same data used for training.

- output_col:

  a character scalar giving the column name to write. If `NULL` (the
  default), the name is taken from [`segment_col`](segment_col.md)`(x)`
  or [`group_col`](segment_col.md)`(x)`.

- ...:

  additional arguments currently unused.

## Value

`new_data` augmented with the fit result.
