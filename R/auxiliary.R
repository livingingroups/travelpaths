
# Swap Strings
#
# Swap character strings within a character vector.
#
# @param x a character vector.
# @param ... key value arguments to be swapped.
#            The syntax is always \code{from = to}.
#
# @examples
# swap(c("bird", "fox", "dog"), fox = "cat", bird = "penguin")
swap <- function(x, ...) {
  checkmate::assert_character(x)
  kwargs <- c(...)
  if (length(kwargs) == 0L) return(x)
  keys <- names(kwargs)
  values <- unname(kwargs)
  checkmate::assert_character(keys, any.missing = FALSE)
  checkmate::assert_character(values, any.missing = FALSE)
  if (all(keys == values)) return(x)
  for (i in seq_along(kwargs)) {
    idx <- which(x == keys[i])
    if (length(idx) > 0) {
      x[idx] <- values[i]
    }
  }
  x
}


# @param old a named list to update.
# @param new a named list of new values.
# @param method a character string giving which parts of the list are
#   updated. Currently allowed values are `"union"` (the default) and `"intersect"`.
#   For `"union"` new values are added to the list.
#   For `"intersect"` only values are updated that are present in both lists.
# @return the updated list `old`.
update_list <- function(old, new, method = c("union", "intersect")) {
  method <- match.arg(method)
  if (method == "union") {
    keys <- names(new)
  } else {
    keys <- intersect(names(old), names(new))
  }
  old[keys] <- new[keys]
  old
}


# Check if a package is installed
#
# Internal function to check whether a specified package is installed
# on the system. Optionally checks for specific methods within the package.
#
# @param pkg Character string specifying the package name to check
# @param methods Character vector of method names to check for within
#   the package. Default is empty vector (no methods checked).
#
# @return Logical value indicating whether the package (and optionally
#   the specified methods) are available
#
# @keywords internal
# @noRd
is_pkg_installed <- function(pkg, methods = c()) {
  ns <- tryCatch(getNamespace(pkg), error = function(e) e)
  if (!inherits(ns, "environment")) {
    return(FALSE)
  }
  if (length(methods) == 0L) {
    return(TRUE)
  }
  all(methods %in% ls(ns))
}
