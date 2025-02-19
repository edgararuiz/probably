% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cal-apply.R
\name{cal_apply}
\alias{cal_apply}
\alias{cal_apply.data.frame}
\alias{cal_apply.tune_results}
\alias{cal_apply.cal_object}
\title{Applies a calibration to a set of pred_class probabilities}
\usage{
cal_apply(.data, object, pred_class = NULL, parameters = NULL, ...)

\method{cal_apply}{data.frame}(.data, object, pred_class = NULL, parameters = NULL, ...)

\method{cal_apply}{tune_results}(.data, object, pred_class = NULL, parameters = NULL, ...)

\method{cal_apply}{cal_object}(.data, object, pred_class = NULL, parameters = NULL, ...)
}
\arguments{
\item{.data}{An object that can process a calibration object.}

\item{object}{The calibration object (\code{cal_object}).}

\item{pred_class}{(Optional) Column identifier for the hard class predictions
(a factor vector). This column will be adjusted based on changes to the
calibrated probability columns.}

\item{parameters}{(Optional)  An optional tibble of tuning parameter values
that can be used to filter the predicted values before processing. Applies
only to \code{tune_results} objects.}

\item{...}{Optional arguments; currently unused.}
}
\description{
Applies a calibration to a set of pred_class probabilities
}
\details{
It currently supports data.frames only. It extracts the \code{truth} and
the estimate columns names, and levels, from the calibration object.
}
\examples{
w_calibration <- cal_estimate_logistic(segment_logistic, Class)

cal_apply(segment_logistic, w_calibration)
}
