% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cal-plot.R
\name{.cal_binary_table_breaks}
\alias{.cal_binary_table_breaks}
\alias{.cal_binary_table_logistic}
\alias{.cal_binary_table_windowed}
\title{Probability Calibration table}
\usage{
.cal_binary_table_breaks(
  .data,
  truth = NULL,
  estimate = NULL,
  group = NULL,
  num_breaks = 10,
  conf_level = 0.9,
  event_level = c("first", "second"),
  ...
)

.cal_binary_table_logistic(
  .data,
  truth = NULL,
  estimate = NULL,
  group = NULL,
  conf_level = 0.9,
  event_level = c("first", "second"),
  ...
)

.cal_binary_table_windowed(
  .data,
  truth = NULL,
  estimate = NULL,
  group = NULL,
  window_size = 0.1,
  step_size = window_size/2,
  conf_level = 0.9,
  event_level = c("first", "second"),
  ...
)
}
\arguments{
\item{.data}{A data.frame object containing predictions and probability columns.}

\item{truth}{The column identifier for the true class results
(that is a factor). This should be an unquoted column name.}

\item{estimate}{The column identifier for the prediction probabilities.
This should be an unquoted column name}

\item{group}{The column identifier to group the results.}

\item{num_breaks}{The number of segments to group the probabilities. It
defaults to 10.}

\item{conf_level}{Confidence level to use in the visualization. It defaults
to 0.9.}

\item{event_level}{single string. Either "first" or "second" to specify which
level of truth to consider as the "event".}

\item{...}{Additional arguments passed to the \code{tune_results} object.}
}
\description{
Calibration table functions. They require a data.frame that
contains the predictions and probability columns. The output is another
\code{tibble} with segmented data that compares the accuracy of the probability
to the actual outcome.
}
\details{
\itemize{
\item \code{.cal_binary_table_breaks()} - Splits the data into bins, based on the
number of breaks provided (\code{num_breaks}). The bins are even ranges, starting
at 0, and ending at 1.
\item \code{.cal_binary_table_logistic()} - Fits a logistic spline regression (GAM)
against the data. It then creates a table with the predictions based on 100
probabilities starting at 0, and ending at 1.
\item \code{.cal_binary_table_windowed()} - Creates a running percentage of the
probability that moves across the proportion of events.
}
}
\examples{
.cal_binary_table_breaks(
  segment_logistic,
  Class,
  .pred_good
)

.cal_binary_table_logistic(
  segment_logistic,
  Class,
  .pred_good
)

.cal_binary_table_windowed(
  segment_logistic,
  Class,
  .pred_good
)
}
\keyword{internal}
