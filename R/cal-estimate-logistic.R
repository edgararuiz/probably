#------------------------------- Methods ---------------------------------------
#' Uses a logistic regression model to calibrate probabilities
#' @param .data A `data.frame` object, or `tune_results` object, that contains
#' predictions and probability columns.
#' @param truth The column identifier for the true class results
#' (that is a factor). This should be an unquoted column name.
#' @param estimate A vector of column identifiers, or one of `dplyr` selector
#' functions to choose which variables contains the class probabilities. It
#' defaults to the prefix used by tidymodels (`.pred_`). The order of the
#' identifiers will be considered the same as the order of the levels of the
#' `truth` variable.
#' @param parameters (Optional)  An optional tibble of tuning parameter values
#' that can be used to filter the predicted values before processing. Applies
#' only to `tune_results` objects.
#' @param ... Additional arguments passed to the models or routines used to
#' calculate the new probabilities.
#' @param smooth Applies to the logistic models. It switches between logistic
#' spline when `TRUE`, and simple logistic regression when `FALSE`.
#' @examples
#' # It will automatically identify the probability columns
#' # if passed a model fitted with tidymodels
#' cal_estimate_logistic(segment_logistic, Class)
#' # Specify the variable names in a vector of unquoted names
#' cal_estimate_logistic(segment_logistic, Class, c(.pred_poor, .pred_good))
#' # dplyr selector functions are also supported
#' cal_estimate_logistic(segment_logistic, Class, dplyr::starts_with(".pred_"))
#' @details
#' This function uses existing modeling functions from other packages to create
#' the calibration:
#' - `stats::glm()` is used when `smooth` is set to `FALSE`
#' - `mgcv::gam()` is used when `smooth` is set to `TRUE`
#' @export
cal_estimate_logistic <- function(.data,
                                  truth = NULL,
                                  estimate = dplyr::starts_with(".pred_"),
                                  smooth = TRUE,
                                  parameters = NULL,
                                  ...) {
  UseMethod("cal_estimate_logistic")
}

#' @export
#' @rdname cal_estimate_logistic
cal_estimate_logistic.data.frame <- function(.data,
                                             truth = NULL,
                                             estimate = dplyr::starts_with(".pred_"),
                                             smooth = TRUE,
                                             parameters = NULL,
                                             ...) {
  stop_null_parameters(parameters)
  cal_logistic_impl(
    .data = .data,
    truth = {{ truth }},
    estimate = {{ estimate }},
    smooth = smooth,
    source_class = cal_class_name(.data),
    ...
  )
}

#' @export
#' @rdname cal_estimate_logistic
cal_estimate_logistic.tune_results <- function(.data,
                                               truth = NULL,
                                               estimate = dplyr::starts_with(".pred_"),
                                               smooth = TRUE,
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
    cal_logistic_impl(
      truth = !!tune_args$truth,
      estimate = !!tune_args$estimate,
      smooth = smooth,
      source_class = cal_class_name(.data),
      ...
    )
}

#--------------------------- Implementation ------------------------------------
cal_logistic_impl <- function(.data,
                              truth = NULL,
                              estimate = dplyr::starts_with(".pred_"),
                              type,
                              smooth,
                              source_class = NULL,
                              ...) {
  if (smooth) {
    model <- "logistic_spline"
    method <- "Logistic Spline"
    additional_class <- "cal_estimate_logistic_spline"
  } else {
    model <- "glm"
    method <- "Logistic"
    additional_class <- "cal_estimate_logistic"
  }

  truth <- enquo(truth)

  levels <- truth_estimate_map(.data, !!truth, {{ estimate }})

  if (length(levels) == 2) {
    log_model <- cal_logistic_impl_grp(
      .data = .data,
      truth = !!truth,
      estimate = levels[[1]],
      run_model = model,
      ...
    )

    res <- as_binary_cal_object(
      estimate = log_model,
      levels = levels,
      truth = !!truth,
      method = method,
      rows = nrow(.data),
      additional_class = additional_class,
      source_class = source_class
    )
  } else {
    stop_multiclass()
  }

  res
}

cal_logistic_impl_grp <- function(.data, truth, estimate, run_model, group, ...) {
  .data %>%
    dplyr::group_by({{ group }}, .add = TRUE) %>%
    split_dplyr_groups() %>%
    lapply(
      function(x) {
        estimate <- cal_logistic_impl_single(
          .data = x$data,
          truth = {{ truth }},
          estimate = estimate,
          run_model = run_model,
          ... = ...
        )
        list(
          filter = x$filter,
          estimate = estimate
        )
      }
    )
}

cal_logistic_impl_single <- function(.data, truth, estimate, run_model, ...) {
  truth <- ensym(truth)

  if (run_model == "logistic_spline") {
    f_model <- expr(!!truth ~ s(!!estimate))
    init_model <- mgcv::gam(f_model, data = .data, family = "binomial", ...)
    model <- butcher::butcher(init_model)
  }

  if (run_model == "glm") {
    f_model <- expr(!!truth ~ !!estimate)
    init_model <- glm(f_model, data = .data, family = "binomial", ...)
    model <- butcher::butcher(init_model)
  }

  model
}
