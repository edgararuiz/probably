test_that("Logistic apply works - data.frame", {
  sl_logistic <- cal_estimate_logistic(segment_logistic, Class, smooth = FALSE)
  ap_logistic <- cal_apply(segment_logistic, sl_logistic)

  pred_good <-  ap_logistic$.pred_good
  expect_equal(mean(pred_good), 0.3425743, tolerance = 0.000001)
  expect_equal(sd(pred_good), 0.2993934, tolerance = 0.000001)
})

test_that("Logistic apply works - tune_results", {
  tct <- testthat_cal_tune_results()
  tl_logistic <- cal_estimate_logistic(tct, smooth = FALSE)
  tap_logistic <- cal_apply(tct, tl_logistic)
  expect_equal(
    testthat_cal_tune_results_count(),
    nrow(tap_logistic)
  )
})

test_that("Logistic spline apply works", {
  sl_gam <- cal_estimate_logistic(segment_logistic, Class)
  ap_gam <- cal_apply(segment_logistic, sl_gam)

  pred_good <-  ap_gam$.pred_good
  expect_equal(mean(pred_good), 0.3425743, tolerance = 0.000001)
  expect_equal(sd(pred_good), 0.2987027, tolerance = 0.000001)
})

test_that("Logistic spline apply works - tune_results", {
  tct <- testthat_cal_tune_results()
  tl_gam <- cal_estimate_logistic(tct)
  tap_gam <- cal_apply(tct, tl_gam)
  expect_equal(
    testthat_cal_tune_results_count(),
    nrow(tap_gam)
  )
})

test_that("Isotonic apply works - data.frame", {
  set.seed(100)

  sl_isotonic <- cal_estimate_isotonic(segment_logistic, Class)
  ap_isotonic <- cal_apply(segment_logistic, sl_isotonic)

  pred_good <-  ap_isotonic$.pred_good
  expect_equal(mean(pred_good), 0.2839132, tolerance = 0.000001)
  expect_equal(sd(pred_good), 0.3079697, tolerance = 0.000001)
})

test_that("Isotonic apply works - tune_results", {
  tct <- testthat_cal_tune_results()
  tl_isotonic <- cal_estimate_isotonic(tct)
  tap_isotonic <- cal_apply(tct, tl_isotonic)
  expect_equal(
    testthat_cal_tune_results_count(),
    nrow(tap_isotonic)
  )
})

test_that("Isotonic Bootstrapped apply works - data.frame", {
  sl_boot <- cal_estimate_isotonic_boot(segment_logistic, Class)
  ap_boot <- cal_apply(segment_logistic, sl_boot)

  expect_true(all(ap_boot$.pred_poor + ap_boot$.pred_good == 1))
})

test_that("Isotonic Bootstrapped apply works - tune_results", {
  tct <- testthat_cal_tune_results()
  tl_boot <- cal_estimate_isotonic_boot(tct)
  tap_boot <- cal_apply(tct, tl_boot)
  expect_equal(
    testthat_cal_tune_results_count(),
    nrow(tap_boot)
  )
})

test_that("Beta apply works - data.frame", {
  sl_beta <- cal_estimate_beta(segment_logistic, Class)
  ap_beta <- cal_apply(segment_logistic, sl_beta)

  pred_good <-  ap_beta$.pred_good
  expect_equal(mean(pred_good), 0.3425743, tolerance = 0.000001)
  expect_equal(sd(pred_good), 0.294565, tolerance = 0.000001)
})

test_that("Beta apply works - tune_results", {
  tct <- testthat_cal_tune_results()
  tl_beta <- cal_estimate_beta(tct)
  tap_beta <- cal_apply(tct, tl_beta)
  expect_equal(
    testthat_cal_tune_results_count(),
    nrow(tap_beta)
  )
})

test_that("Passing the data frame first returns expected abort message", {
  sl_boot <- cal_estimate_isotonic_boot(segment_logistic, Class)

  expect_error(
    cal_apply(sl_boot, segment_logistic)
    )
})

test_that("Passing a tune_results without saved predictions causes error", {
  tct <- testthat_cal_tune_results()
  tl_beta <- cal_estimate_beta(tct)
  expect_error(cal_apply(tune::ames_grid_search, tl_beta))
})

