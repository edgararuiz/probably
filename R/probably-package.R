#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import rlang
#' @import vctrs
#' @import ggplot2
#' @importFrom magrittr %>%
#' @importFrom purrr map
#' @importFrom utils head
#' @importFrom yardstick sens spec j_index
#' @importFrom stats binomial median predict qnorm as.stepfun glm isoreg
## usethis namespace: end
NULL

utils::globalVariables(c(
  ".bin", ".is_val", "event_rate", "events", "lower",
  "predicted_midpoint", "total", "upper", ".config",
  ".adj_estimate", ".rounded"
))
