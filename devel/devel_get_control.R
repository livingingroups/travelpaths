library("checkmate")
library("travelpaths")
attach(getNamespace("travelpaths"))


spec <- change_point_permtest()
object <- spec


get_control_function(object)
