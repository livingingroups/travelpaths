# TODOs

## Differences to tidymodels and tidyclust

- tidy.\* have a translate function which add additional info to the
  spec. I currently do that differently and don’t think we need it.
- I export the new_spec function because otherwise it gets hard for
  users to extend it.
- I use a register of functions into the package namespace to allow
  package developers to extend the travelpaths package.

### tidymodels

tidymodels and tidyclust add the record `"method"` to the fitted object.

`method` looks as follows:

    List of 3
     $ libs: chr "ranger"
     $ fit :List of 6
      ..$ interface: chr "data.frame"
      ..$ data     : Named chr [1:3] "x" "y" "case.weights"
      .. ..- attr(*, "names")= chr [1:3] "x" "y" "weights"
      ..$ protect  : chr [1:3] "x" "y" "weights"
      ..$ func     : Named chr [1:2] "ranger" "ranger"
      .. ..- attr(*, "names")= chr [1:2] "pkg" "fun"
      ..$ defaults :List of 3
      .. ..$ num.threads: num 1
      .. ..$ verbose    : logi FALSE
      .. ..$ seed       : language sample.int(10^5, 1)
      ..$ args     :List of 8
      .. ..$ x          : language missing_arg()
      .. ..$ y          : language missing_arg()
      .. ..$ weights    : language missing_arg()
      .. ..$ num.trees  : language ~100
      .. .. ..- attr(*, ".Environment")=<environment: R_EmptyEnv>
      .. ..$ num.threads: num 1
      .. ..$ verbose    : logi FALSE
      .. ..$ seed       : language sample.int(10^5, 1)
      .. ..$ probability: logi TRUE
     $ pred:List of 4
      ..$ class   :List of 4
      .. ..$ pre : NULL
      .. ..$ post:function (results, object)
      .. ..$ func: Named chr "predict"
      .. .. ..- attr(*, "names")= chr "fun"
      .. ..$ args:List of 5
      ..$ prob    :List of 4
      .. ..$ pre :function (x, object)
      .. ..$ post:function (x, object)
      .. ..$ func: Named chr "predict"
      .. .. ..- attr(*, "names")= chr "fun"
      .. ..$ args:List of 4
      ..$ conf_int:List of 4
      .. ..$ pre : NULL
      .. ..$ post: NULL
      .. ..$ func: Named chr "ranger_confint"
      .. .. ..- attr(*, "names")= chr "fun"
      .. ..$ args:List of 3
      ..$ raw     :List of 4
      .. ..$ pre : NULL
      .. ..$ post: NULL
      .. ..$ func: Named chr "predict"
      .. .. ..- attr(*, "names")= chr "fun"
      .. ..$ args:List of 3

### tidymodels fit

We currently return a trackframe from the fit function, which is
inconsistent with the fit from tidymodels and tidyclust. tidyclust also
has a similar fit object and uses, - predict to return a tibble with a
single column and - augment to add the column to the newdata input of
the augment function.

## smoove wrapper

- We currently have the arguments progress and verbose. I think we
  should change it to one parameter.
