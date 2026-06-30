# Constructor for travelpath specification objects

\`new_travelpath_spec()\` is a developer-oriented constructor function
for creating new travelpath specification objects. This function is used
internally by user-facing specification functions.

## Usage

``` r
new_travelpath_spec(cls, args, eng_args, mode, engine)
```

## Arguments

- cls:

  a character string for the class of the specification (e.g.,
  "stop_detection").

- args:

  a list of main arguments for the specification.

- eng_args:

  a list of engine-specific arguments, typically an empty \`list()\` or
  \`NULL\` when creating a new specification.

- mode:

  a character string for the type of travel path analysis. Possible
  values are "segmentation" or "grouping" or "unknown".

- engine:

  a character string for the computational engine.

## Value

A travelpath specification object with class \`cls\`.
