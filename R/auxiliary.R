

#' @param old a named list to update.
#' @param new a named list of new values.
#' @param method `"union"` updates all keys from `new`; `"intersect"` updates only keys present
#'   in both.
#' @return the updated list `old`.
#' @keywords internal
#' @noRd
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
