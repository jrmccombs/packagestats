################################################################################
# Copyright 2016 Indiana University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

#' Performs logging of package utilization by the base::library function
#'
#' \code{library} performs logging of package utilization by R sessions when
#' the \code{\link[base]{library}} function is called
#'
#' This function performs logging of package utilization by R sessions when
#' the \code{\link[base]{library}} function is called to load packages.  When
#' the \code{packagestats} package is loaded, the \code{\link{library}}
#' function overloads the \code{\link[base]{library}} function so that the
#' name of the loaded package and other identifying information can be recorded
#' in a log file once the \code{\link[base]{library}} function returns
#' successfully.  A single log file in CSV format is created for the R session
#' during the first call to \code{library} or \code{require}.  Each time a
#' package is loaded, the log file is appended with the identifying information
#' of the package and R session.  The identifying information written to each
#' line of the log file is:
#' \enumerate{
#'   \item the name of the R script file as returned by
#'      \code{\link[base]{commandArgs}} under the \code{--file} option, or the
#'      empty string if the session is interactive
#'   \item the version of the R programming environment
#'   \item the name of the package loaded
#'   \item the version of the package loaded
#'   \item the user's login name as returned by \code{\link[base]{Sys.info}}
#'   \item the real name of the user as returned by \code{\link[base]{Sys.info}}
#'   \item the name of the effective user as returned by \code{\link[base]{Sys.info}}
#' }
#' The log file will be in the directory specified by the option
#' \code{package.stats.logDirectory} and have the format
#' \code{logFilePrefix_nodename_processId} where \code{logFilePrefix} is a
#' character string defined by the option \code{package.stats.logFilePrefix},
#' \code{nodename} is the node name returned by \code{\link[base]{Sys.info}},
#' and \code{processId} is the process identifier of the R session.
#'
#' @inheritParams base::library
#' @export
library <-
function(package, help, pos = 2, lib.loc = NULL, character.only = FALSE,
         logical.return = FALSE, warn.conflicts = TRUE,
         quietly = FALSE, verbose = getOption("verbose")) {

   # If the package parameter is missing, then no package is to be loaded and
   # the help parameter should be checked.  If neither the package or help
   # parameters is provided, then the current available packages should be
   # returned.
   if (!missing(package)) {
      # Convert name to string
      if (!character.only) {
         package <- as.character(substitute(package))
      }

      # If the help parameter is missing, then the package is to be loaded
      if (missing(help)) {
         print("Calling base::library 1")
         r <- base::library(package=package, pos=pos, lib.loc=lib.loc,
                 character.only=TRUE, logical.return=logical.return,
		 warn.conflicts=warn.conflicts, quietly=quietly,
                 verbose=verbose)
      } else {
         # This case occurs when the package and the help parameters
         # are both provided.
         print("Calling base::library 2")
         r <- base::library(package=package, help=help, pos=pos,
                 lib.loc=lib.loc, character.only=TRUE,
                 logical.return=logical.return, warn.conflicts=warn.conflicts,
                 quietly=quietly, verbose)
      }

      # Save the statistics to a session log file
      pkgVersion <- toString(utils::packageVersion(package))
      print("calling collectStatistics")
      collectStatistics(package, pkgVersion)
      print("after collectStatistics")
   } else if (!missing(help)) {
      if (!character.only) {
         help <- as.character(substitute(help))
      }

      print("Calling base::library 3")
      r <- base::library(help=help, pos=pos, lib.loc=lib.loc,
                    character.only=TRUE, logical.return=logical.return,
                    warn.conflicts=warn.conflicts, quietly=quietly,
                    verbose=verbose)
      return(r)
   } else {
      print("Calling base::library 4")
      r <- base::library(pos=pos, lib.loc=lib.loc,
         character.only=character.only, logical.return=logical.return,
         warn.conflicts=warn.conflicts, quietly=quietly, verbose=verbose)
      return(r)
   }

   if (logical.return) {
      r
   } else {
      invisible(r)
   }
}


#' Performs logging of package utilization by the base::require function
#'
#' \code{require} performs logging of package utilization by R sessions when
#' the \code{\link[base]{require}} function is called
#'
#' This function performs logging of package utilization by R sessions when
#' the \code{\link[base]{require}} function is called to load packages.  When
#' the \code{packagestats} package is loaded, the \code{\link{require}}
#' function overloads the \code{\link[base]{require}} function so that the
#' name of the loaded package and other identifying information can be recorded
#' in a log file once the \code{\link[base]{require}} function returns
#' successfully.  A single log file in CSV format is created for the R session
#' during the first call to \code{require} or \code{library} functions.  Each
#' time a package is loaded, the log file is appended with the identifying
#' information of the package and R session.  The identifying information
#' written to each line of the log file is:
#' \enumerate{
#'   \item the name of the R script file as returned by \code{\link[base]{commandArgs}} under the \code{--file} option, or the empty string if the session is interactive
#'   \item the version of the R programming environment
#'   \item the name of the package loaded
#'   \item the version of the package loaded
#'   \item the user's login name as returned by \code{\link[base]{Sys.info}}
#'   \item the real name of the user as returned by \code{\link[base]{Sys.info}}
#'   \item the name of the effective user as returned by \code{\link[base]{Sys.info}}
#' }
#' The log file will be in the directory specified by the option
#' \code{package.stats.logDirectory} and have the format
#' \code{logFilePrefix_nodename_processId} where \code{logFilePrefix} is a
#' character string defined by the option \code{package.stats.logFilePrefix},
#' \code{nodename} is the node name returned by \code{\link[base]{Sys.info}},
#' and \code{processId} is the process identifier of the R session.
#' 
#' @inheritParams base::require
#' @export
require <-
function(package, lib.loc = NULL, quietly = FALSE, warn.conflicts = TRUE,
         character.only = FALSE) {

   if (!character.only) {
      package <- as.character(substitute(package))
   }

   r <- base::require(package=package, lib.loc=lib.loc, quietly=quietly,
           warn.conflicts=warn.conflicts, character.only=TRUE)

   pkgVersion <- toString(utils::packageVersion(package))
   collectStatistics(package, pkgVersion)

   invisible(r)
}


#' Retrieves and writes the user and R session identifying information to
#' session log files
#'
#' \code{collectStatistics} retrieves needed user and R session identifying
#' information and writes it to the session log file
#'
#' Retrieves and appends package and R session identifying information to a log
#' file for saving this information.  The identifying information written to
#' each line of the log file is:
#' \enumerate{
#'   \item the name of the R script file as returned by
#'      \code{\link[base]{commandArgs}} under the \code{--file} option, or the
#'      empty string if the session is interactive
#'   \item the version of the R programming environment
#'   \item the name of the package loaded
#'   \item the version of the package loaded
#'   \item the user's login name as returned by \code{\link[base]{Sys.info}}
#'   \item the real name of the user as returned by \code{\link[base]{Sys.info}}
#'   \item the name of the effective user as returned by \code{\link[base]{Sys.info}}
#' }
#' The log file will be in the directory specified by the option
#' \code{package.stats.logDirectory} and have the format
#' \code{logFilePrefix_nodename_processId} where \code{logFilePrefix} is a
#' character string defined by the option \code{package.stats.logFilePrefix},
#' \code{nodename} is the node name returned by \code{\link[base]{Sys.info}},
#' and \code{processId} is the process identifier of the R session.
#'
#' @param pkgName the name of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @param pkgVersion the version of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' 
collectStatistics <-
function(pkgName, pkgVersion) {

   ownPackageName <- methods::getPackageName()
   enableCollectionOption <- "package.stats.enabled"
   methodOption <- "package.stats.method"
   logDirOption <- "package.stats.logDirectory"
   logFilePrefixOption <- "package.stats.logFilePrefix"
   logFilePrefix <- getOption(logFilePrefixOption)
   logDirectory <- getOption(logDirOption)
   cat(sprintf("logDirectory: %s\n", logDirectory))
   csvLabels <- "ScriptFile,R Version,PackageName,PackageVersion,UserLogin,UserName,EffectiveUser\n"

   # Make sure needed options are set
   if (is.null(getOption(enableCollectionOption))) {
      stop(sprintf("%s: Option `%s` must be set to TRUE or FALSE",
         ownPackageName, enableCollectionOption))
   } else if (is.null(logFilePrefix) || is.null(logDirectory)) {
      warning(sprintf("%s: Options `%s` and `%s` must be set to enable package utilization statistics",
         ownPackageName, logFilePrefix, logDirectory))
      # Deactivate package statistics collection
      options(package.stats.enabled = FALSE)
   } else {
      # Check existence of logging directory
      if (!dir.exists(logDirectory)) {
         warning(sprintf("%s: Package utilization statistics logging directory '%s' is not found.  Disabling package utilization statistics for this session.", ownPackageName, logDirectory))

         # Deactivate package statistics collection
         options(package.stats.enabled = FALSE)
      }
   }

   # If statistics collection is still active,
   # collect the needed information and save it to a log file.
   if (getOption(enableCollectionOption) == TRUE) {
      method <- getOption(methodOption)

      if (method == "log") {
         logDirectory <- getOption(logDirOption)
         writeCsvLogFile(ownPackageName, pkgName, pkgVersion,
            logFilePrefixOption, logDirOption, csvLabels)
      } else if (method == "xalt") {
         # If the XALT_RUN_UUID is set, then tracking is enabled.
         # XALT_EXECUTABLE_TRACKING should NOT be examined for this purpose.
         run_uuid <- Sys.getenv("XALT_RUN_UUID")
      }
   }

   print("returning successfully from collectStatistics")
}


writeCsvLogFile <-
function(ownPackageName, pkgName, pkgVersion, logDirOption, logFilePrefixOption,
   csvLabels) {
   logDirectory <- getOption(logDirOption)

   # Check if the logging directory exists.
   # If not, disable the statistics collection.
   if (is.null(logDirectory)) {
      warning(sprintf("%s: Option %s is not set.  Disabling package utilization statistics for this session.", ownPackageName, logDirOption))
      options(package.stats.enabled = FALSE)
   } else {
   
      # Call Sys.info to get user stats
      # If running Rscript, how do we get the top level R script?
      # need to append to process id file

      systemInfo <- Sys.info()
      processId <- Sys.getpid()
      logFilePrefix <- getOption(logFilePrefixOption)
      
      tempFileName <- paste(logFilePrefix,
         systemInfo[["nodename"]], processId, sep="_")
      tempFilePath <- file.path(logDirectory, tempFileName)

      fileExists <- file.exists(tempFilePath)

      print("checking if !fileExists")

      # If the log file does not exist for the current R session,
      # then create one.
      if (!fileExists) {
         fileCreated <- file.create(tempFilePath)

         # Check if the file was created successfully.  If not,
         # then deactivate the statistics collection.
         if (fileCreated) {
            cat(csvLabels, file=tempFilePath, append=TRUE)
            fileExists <- TRUE
         } else {
            warning(sprintf("%s: Cannot create package utilization statistics log file '%s'.  Disabling package utilization statistics for this session.", ownPackageName, tempFilePath))
            options(package.stats.enabled = FALSE)
         }
      }

      # If the file exists, write the needed information to the session
      # log file. 
      if (fileExists) {
         argList <- commandArgs(trailingOnly=FALSE) 

         scriptFile <- ""

         # Find the name of the script file
         for (a in argList) {
            if (grepl("--file=", a)) {
               scriptFile <- substr(a, 8, nchar(a)) 
            }
         }

         # Get the R version
         rVersion <- paste(R.version$major, R.version$minor, sep=".")

         sep <- c(",", ",", ",", ",", ",", ",", "")
         cat(scriptFile, rVersion, pkgName, pkgVersion,
            systemInfo[["login"]], systemInfo[["user"]],
            systemInfo[["effective_user"]], "\n", file=tempFilePath, sep=sep,
            append=TRUE)
      }
   }
}



