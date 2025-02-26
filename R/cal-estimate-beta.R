#-------------------------------- Methods --------------------------------------
#' Uses a Beta calibration model to calculate new probabilities
#' @param shape_params Number of shape parameters to use. Accepted values are
#' 1 and 2. Defaults to 2.
#' @param location_params Number of location parameters to use. Accepted values
#' 1 and 0. Defaults to 1.
#' @inheritParams cal_estimate_logistic
#' @details  This function uses the `betcal::beta_calibration()` function, and
#' retains the resulting model.
#' @references Meelis Kull, Telmo M. Silva Filho, Peter Flach "Beyond sigmoids:
#' How to obtain well-calibrated probabilities from binary classifiers with beta
#' calibration," _Electronic Journal of Statistics_ 11(2), 5052-5080, (2017)
#' @examples
#' # It will automatically identify the probability columns
#' # if passed a model fitted with tidymodels
#' cal_estimate_beta(segment_logistic, Class)
#' @export
cal_estimate_beta <- function(.data,
                              truth = NULL,
                              shape_params = 2,
                              location_params = 1,
                              estimate = dplyr::starts_with(".pred_"),
                              parameters = NULL,
                              ...) {
  UseMethod("cal_estimate_beta")
}

#' @export
#' @rdname cal_estimate_beta
cal_estimate_beta.data.frame <- function(.data,
                                         truth = NULL,
                                         shape_params = 2,
                                         location_params = 1,
                                         estimate = dplyr::starts_with(".pred_"),
                                         parameters = NULL,
                                         ...) {
  stop_null_parameters(parameters)
  cal_beta_impl(
    .data = .data,
    truth = {{ truth }},
    shape_params = shape_params,
    location_params = location_params,
    estimate = {{ estimate }},
    source_class = cal_class_name(.data),
    ...
  )
}

#' @export
#' @rdname cal_estimate_beta
cal_estimate_beta.tune_results <- function(.data,
                                           truth = NULL,
                                           shape_params = 2,
                                           location_params = 1,
                                           estimate = dplyr::starts_with(".pred_"),
                                           parameters = NULL,
                                           ...) {
  tune_args <- tune_results_args(
    .data = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    group = NULL,
    event_level = "first",
    parameters = parameters,
    ...
  )

  tune_args$predictions %>%
    dplyr::group_by(!!tune_args$group) %>%
    cal_beta_impl(
      truth = !!tune_args$truth,
      estimate = !!tune_args$estimate,
      shape_params = shape_params,
      location_params = location_params,
      source_class = cal_class_name(.data),
      ...
    )
}


# ----------------------------- Implementation ---------------------------------

cal_beta_impl <- function(.data,
                          truth = NULL,
                          shape_params = 2,
                          location_params = 1,
                          estimate = dplyr::starts_with(".pred_"),
                          source_class = NULL,
                          ...) {
  truth <- enquo(truth)
  estimate <- enquo(estimate)

  levels <- truth_estimate_map(.data, !!truth, !!estimate)

  if (length(levels) == 2) {
    beta_model <- cal_beta_impl_grp(
      .data = .data,
      truth = !!truth,
      shape_params = shape_params,
      location_params = location_params,
      estimate = !!levels[[1]],
      levels = levels,
      ...
    )

    res <- as_binary_cal_object(
      estimate = beta_model,
      levels = levels,
      truth = {{ truth }},
      method = "Beta",
      rows = nrow(.data),
      source_class = source_class,
      additional_class = "cal_estimate_beta"
    )
  } else {
    stop_multiclass()
  }

  res
}

cal_beta_impl_grp <- function(.data,
                              truth = NULL,
                              shape_params = 2,
                              location_params = 1,
                              estimate = NULL,
                              levels = NULL,
                              ...) {
  .data %>%
    split_dplyr_groups() %>%
    lapply(
      function(x) {
        estimate <- cal_beta_impl_single(
          .data = .data,
          truth = {{ truth }},
          shape_params = shape_params,
          location_params = location_params,
          estimate = {{ estimate }},
          levels = levels,
          ...
        )
        list(
          filter = x$filter,
          estimate = estimate
        )
      }
    )
}

cal_beta_impl_single <- function(.data,
                                 truth = NULL,
                                 shape_params = 2,
                                 location_params = 1,
                                 estimate = NULL,
                                 levels = NULL,
                                 ...) {
  x_factor <- dplyr::pull(.data, {{ truth }})
  x <- x_factor == names(levels[1])
  y <- dplyr::pull(.data, {{ estimate }})

  parameters <- NULL

  if (shape_params == 1) {
    parameters <- "a"
  }

  if (shape_params == 2) {
    parameters <- "ab"
  }

  if (location_params == 1) {
    parameters <- paste0(parameters, "m")
  }

  if (location_params > 1) {
    rlang::abort("Invalid `location_params`, allowed values are 1 and 0")
  }

  if (is.null(parameters)) {
    rlang::abort("Invalid `shape_params`, allowed values are 1 and 2")
  }

  prevent_output <- utils::capture.output(
    beta_model <- invisible(betacal::beta_calibration(
      p = y,
      y = x,
      parameters = parameters
    ))
  )

  beta_model$model <- butcher::butcher(beta_model$model)

  beta_model
}
