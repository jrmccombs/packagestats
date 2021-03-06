#' packagestats: A package for collecting package utilization statistics for
#' packages loaded using the \code{library}, \code{require}, and namespace
#' operators.
#'
#' The package works by overlaying the `base::library`, `base:require`, and
#' `::` functions with identically named functions with the same function
#' definitions.  These overlay functions save the names of the packages and
#' other identifying information to a session log file uniquely associated with
#' the instance of the R programming environment.
#'
#' @section Top-level functions:
#' \describe{
#'    \item{\code{\link{library}}}{Calls the \code{base::library} function and
#'      records the package name, version, and other information for regarding
#'      package utilization}
#'    \item{\code{\link{require}}}{Calls the \code{base::require} function and
#'      records the package name, version, and other information for regarding
#'      package utilization}
#'    \item{\code{::}}{Calls the \code{base::'::'} function and 
#'      records the package name, version, and other information for regarding
#'      package utilization}
#' }
#'
#' @docType package
#' @name packagestats
NULL
