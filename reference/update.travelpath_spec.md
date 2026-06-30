# Update a travelpath specification object

Update the parameters of a travelpath specification object with new
values. This function allows you to modify the arguments and
engine-specific arguments of an existing travelpath specification.

## Usage

``` r
# S3 method for class 'travelpath_spec'
update(object, params = list(), fresh = FALSE, ...)
```

## Arguments

- object:

  A travelpath specification object to be updated.

- params:

  A named list of parameters to update. The function will automatically
  determine which parameters are main arguments vs engine-specific
  arguments based on the specification's formal arguments.

- fresh:

  A logical value indicating whether to start with fresh default values
  (\`TRUE\`) or preserve existing parameter values (\`FALSE\`, default).
  When \`TRUE\`, only the parameters specified in \`params\` will be
  set, all others will revert to defaults.

- ...:

  Additional named parameters to update. These will be combined with the
  \`params\` list.

## Value

An updated travelpath specification object with the same class as the
input object.

## Examples

``` r
spec <- threshold_stops(min_staying_time = 5)
updated_spec <- update(spec, params = list(min_staying_time = 10))
fresh_spec <- update(spec, fresh = TRUE, min_staying_time = 15)
```
