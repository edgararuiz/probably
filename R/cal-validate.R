# -------------------------------- Logistic ------------------------------------
#' Measure performance of a logistic regression calibration
#' @details These functions take an re-sampled object, created via `rsample`,
#' and for each re-sample, it calculates the calibration on the training set, and
#' then applies the calibration on the assessment set. By default the average of
#' Brier scores is returned. It compares the average of the metrics before, and
#' after the calibration.
#' Please note that this function does not apply to `tune_result` objects. It
#' only processes re-sampled data.
#' @param metrics A set of metrics passed created via `yardstick::metric_set()`
#' @param summarize Indicates to pass tibble with the metrics averaged, or
#' if to return the same sampled object but with new columns containing the
#' calibration y validation list columns.
#' @param save_details Indicates whether to include the `calibration` and
#' `validation` columns when the `summarize` argument is set to FALSE.
#' @examples
#'
#' library(magrittr)
#'
#' segment_logistic %>%
#'   rsample::vfold_cv() %>%
#'   cal_validate_logistic(Class)
#'
#' @inheritParams cal_estimate_logistic
#' @param .data A `data.frame` object, or `rset` object, that contains
#' predictions and probability columns.
#' @export
cal_validate_logistic <- function(.data,
                                  truth = NULL,
                                  estimate = dplyr::starts_with(".pred_"),
                                  smooth = TRUE,
                                  parameters = NULL,
                                  metrics = NULL,
                                  save_details = FALSE,
                                  summarize = TRUE,
                                  ...) {
  UseMethod("cal_validate_logistic")
}

#' @export
#' @rdname cal_validate_logistic
cal_validate_logistic.rset <- function(.data,
                                       truth = NULL,
                                       estimate = dplyr::starts_with(".pred_"),
                                       smooth = TRUE,
                                       parameters = NULL,
                                       metrics = NULL,
                                       save_details = FALSE,
                                       summarize = TRUE,
                                       ...) {
  cal_validate(
    rset = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    cal_function = "logistic",
    metrics = metrics,
    summarize = summarize,
    smooth = smooth,
    parameters = parameters,
    save_details = save_details,
    ...
  )
}

# -------------------------------- Isotonic ------------------------------------
#' Measure performance of a Isotonic regression calibration
#' @inherit cal_validate_logistic
#' @inheritParams cal_estimate_isotonic
#' @examples
#'
#' library(magrittr)
#'
#' segment_logistic %>%
#'   rsample::vfold_cv() %>%
#'   cal_validate_isotonic(Class)
#'
#' @export
cal_validate_isotonic <- function(.data,
                                  truth = NULL,
                                  estimate = dplyr::starts_with(".pred_"),
                                  parameters = NULL,
                                  metrics = NULL,
                                  save_details = FALSE,
                                  summarize = TRUE,
                                  ...) {
  UseMethod("cal_validate_isotonic")
}

#' @export
#' @rdname cal_validate_isotonic
cal_validate_isotonic.rset <- function(.data,
                                       truth = NULL,
                                       estimate = dplyr::starts_with(".pred_"),
                                       parameters = NULL,
                                       metrics = NULL,
                                       save_details = FALSE,
                                       summarize = TRUE,
                                       ...) {
  cal_validate(
    rset = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    cal_function = "isotonic",
    metrics = metrics,
    summarize = summarize,
    save_details = save_details,
    ...
  )
}

# ----------------------------- Isotonic Boot ----------------------------------
#' Measure performance of a Isotonic regression calibration
#' @inherit cal_validate_logistic
#' @inheritParams cal_estimate_isotonic_boot
#' @examples
#'
#' library(magrittr)
#'
#' segment_logistic %>%
#'   rsample::vfold_cv() %>%
#'   cal_validate_isotonic_boot(Class)
#'
#' @export
cal_validate_isotonic_boot <- function(.data,
                                       truth = NULL,
                                       estimate = dplyr::starts_with(".pred_"),
                                       times = 10,
                                       parameters = NULL,
                                       metrics = NULL,
                                       save_details = FALSE,
                                       summarize = TRUE,
                                       ...) {
  UseMethod("cal_validate_isotonic_boot")
}

#' @export
#' @rdname cal_validate_isotonic_boot
cal_validate_isotonic_boot.rset <- function(.data,
                                            truth = NULL,
                                            estimate = dplyr::starts_with(".pred_"),
                                            times = 10,
                                            parameters = NULL,
                                            metrics = NULL,
                                            save_details = FALSE,
                                            summarize = TRUE,
                                            ...) {
  cal_validate(
    rset = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    cal_function = "isotonic_boot",
    metrics = metrics,
    summarize = summarize,
    save_details = save_details,
    ...
  )
}

# ---------------------------------- Beta --------------------------------------
#' Measure performance of Beta calibration
#' @inherit cal_validate_logistic
#' @inheritParams cal_estimate_beta
#' @examples
#'
#' library(magrittr)
#'
#' segment_logistic %>%
#'   rsample::vfold_cv() %>%
#'   cal_validate_beta(Class)
#'
#' @export
cal_validate_beta <- function(.data,
                              truth = NULL,
                              shape_params = 2,
                              location_params = 1,
                              estimate = dplyr::starts_with(".pred_"),
                              parameters = NULL,
                              metrics = NULL,
                              summarize = TRUE,
                              save_details = FALSE,
                              ...) {
  UseMethod("cal_validate_beta")
}

#' @export
#' @rdname cal_validate_beta
cal_validate_beta.rset <- function(.data,
                                   truth = NULL,
                                   shape_params = 2,
                                   location_params = 1,
                                   estimate = dplyr::starts_with(".pred_"),
                                   parameters = NULL,
                                   metrics = NULL,
                                   summarize = TRUE,
                                   save_details = FALSE,
                                   ...) {
  cal_validate(
    rset = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    cal_function = "beta",
    metrics = metrics,
    summarize = summarize,
    shape_params = shape_params,
    location_params = location_params,
    save_details = save_details,
    ...
  )
}

# --------------------------------- Summary ------------------------------------
#' Summarizes the metrics of a Calibrated Re-sampled set
#' @param x Calibrated Re-sampled set
#' @export
cal_validate_summarize <- function(x) {
  UseMethod("cal_validate_summarize")
}

#' @rdname cal_validate_summarize
#' @export
cal_validate_summarize.cal_rset <- function(x) {
  fs <- x$stats_after[[1]]

  fs$.estimate <- NULL

  seq_len(nrow(fs)) %>%
    map(~ {
      y <- .x
      ret <- fs[y, ]

      sb <- purrr::map_dbl(x$stats_before, ~ .x[y, ]$.estimate)
      ret1 <- ret
      ret1$stage <- "uncalibrated"
      ret1$.estimate <- mean(sb)

      sa <- purrr::map_dbl(x$stats_after, ~ .x[y, ]$.estimate)
      ret2 <- ret
      ret2$stage <- "calibrated"
      ret2$.estimate <- mean(sa)

      dplyr::bind_rows(ret1, ret2)
    }) %>%
    dplyr::bind_rows()
}

# ------------------------------ Implementation --------------------------------
cal_validate <- function(rset,
                         truth = NULL,
                         estimate = NULL,
                         cal_function = NULL,
                         metrics = NULL,
                         summarize = TRUE,
                         save_details = FALSE,
                         ...) {
  truth <- enquo(truth)
  estimate <- enquo(estimate)

  if (is.null(cal_function)) rlang::abort("No calibration function provided")

  if (is.null(metrics)) {
    metrics <- yardstick::metric_set(
      yardstick::brier_class
    )
  }

  direction <- metrics %>%
    tibble::as_tibble() %>%
    dplyr::select("direction") %>%
    head(1) %>%
    dplyr::pull()

  data_tr <- purrr::map(rset$splits, rsample::analysis)
  data_as <- purrr::map(rset$splits, rsample::assessment)

  if (cal_function == "logistic") {
    cals <- purrr::map(
      data_tr,
      cal_estimate_logistic,
      truth = !!truth,
      estimate = !!estimate,
      ...
    )
  }

  if (cal_function == "isotonic") {
    cals <- purrr::map(
      data_tr,
      cal_estimate_isotonic,
      truth = !!truth,
      estimate = !!estimate,
      ...
    )
  }

  if (cal_function == "isotonic_boot") {
    cals <- purrr::map(
      data_tr,
      cal_estimate_isotonic_boot,
      truth = !!truth,
      estimate = !!estimate,
      ...
    )
  }

  if (cal_function == "beta") {
    cals <- purrr::map(
      data_tr,
      cal_estimate_beta,
      truth = !!truth,
      estimate = !!estimate,
      ...
    )
  }

  estimate_col <- cals[[1]]$levels[[1]]

  applied <- seq_along(data_as) %>%
    purrr::map(
      ~ {
        ap <- cal_apply(
          .data = data_as[[.x]],
          object = cals[[.x]],
          pred_class = rlang::parse_expr(".pred_class")
          )

        stats_after <- metrics(ap, truth = !!truth, estimate_col)
        stats_before <- metrics(data_as[[.x]], truth = !!truth, estimate_col)

        stats_cols <- c(".metric", ".estimator", "direction", ".estimate")
        stats_after$direction <- direction
        stats_after <- stats_after[, stats_cols]
        stats_before$direction <- direction
        stats_before <- stats_before[, stats_cols]

        list(
          ap = ap,
          stats_after = stats_after,
          stats_before = stats_before
        )
      }
    ) %>%
    purrr::transpose()

  if(save_details) {
    rset <- dplyr::mutate(
      rset,
      calibration = cals,
      validation = applied$ap
    )
  }

  ret <- dplyr::mutate(
    rset,
    stats_after = applied$stats_after,
    stats_before = applied$stats_before
  )

  class(ret) <- c("cal_rset", class(ret))

  if (summarize) {
    ret <- cal_validate_summarize(ret)
  }

  ret
}

#' @importFrom pillar type_sum
#' @export
type_sum.cal_binary <- function(x, ...) {
  paste0(x$method, " [", x$rows, "]")
}
