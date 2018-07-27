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

#' Performs logging of package utilization by R scripts that call the
#' \code{library} function to load packages
#'
#' \code{\link{library}} performs logging of package utilization by R sessions
#' when the \code{base::library} function is called
#'
#' This function performs logging of package utilization by R sessions when
#' packages are loaded using calls to \code{library}.  The
#' \code{packagestats} package must appear in the search path before
#' \code{base} for the logging to work properly.  The \code{\link{library}}
#' function overloads the \code{base::library} function so that the
#' name of the loaded package and other identifying information can be logged
#' once the \code{base::library} function returns successfully.  See the package
#' README.md or vignette for details on how to configure logging.
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
         r <- base::library(package=package, pos=pos, lib.loc=lib.loc,
                 character.only=TRUE, logical.return=logical.return,
		 warn.conflicts=warn.conflicts, quietly=quietly,
                 verbose=verbose)
      } else {
         # This case occurs when the package and the help parameters
         # are both provided.
         r <- base::library(package=package, help=help, pos=pos,
                 lib.loc=lib.loc, character.only=TRUE,
                 logical.return=logical.return, warn.conflicts=warn.conflicts,
                 quietly=quietly, verbose)
      }

      packagePath <- tryCatch({
         pkgPath <- find.package(package=package) 
         pkgPath
      }, error = function(err) {
         return("")
      })

      # Write the logging information
      collectStatistics(package, packagePath)
   } else if (!missing(help)) {
      if (!character.only) {
         help <- as.character(substitute(help))
      }

      r <- base::library(help=help, pos=pos, lib.loc=lib.loc,
                    character.only=TRUE, logical.return=logical.return,
                    warn.conflicts=warn.conflicts, quietly=quietly,
                    verbose=verbose)
      return(r)
   } else {
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


#' Performs logging of package utilization by R scripts that call the
#' \code{require} function to load packages
#'
#' \code{\link{require}} performs logging of package utilization by R sessions
#' when the \code{base::require} function is called
#'
#' This function performs logging of package utilization by R sessions when
#' packages are loaded using calls to \code{require}.  The
#' \code{packagestats} package must appear in the search path before
#' \code{base} for the logging to work properly.  The \code{\link{require}}
#' function overloads the \code{base::require} function so that the
#' name of the loaded package and other identifying information can be logged
#' once the \code{base::require} function returns successfully.  See the package
#' README.md or vignette for details on how to configure logging.
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

   packagePath <- tryCatch({
      pkgPath <- find.package(package=package) 
      pkgPath
   }, error = function(err) {
      return("")
   })
      
   collectStatistics(package, packagePath)
   invisible(r)
}


#' Overloads the :: operator to track package utilization 
#'
#' \code{::} performs logging of package utilization by R sessions when
#' the \code{::} function is called
#' 
#' Implements the \code{::} operator from R version 3.4.0 with a function
#' call to \code{\link{collectStatistics}} to log the package utilization
#' statistics for the package accessed by the operator.  This function
#' must be updated whenver the implementation of \code{base::'::'} is
#' changed in a new release of the R programming environment.
#' 
#' @param pkg the name of the package the function is a member of
#' @param name the function name
#' @export
`::` <- function(pkg, name) {
   pkg <- as.character(substitute(pkg))
   name <- as.character(substitute(name))

   pkgPath <- tryCatch({
      find.package(package=pkg) 
   }, error = function(err) {
      return("")
   })
 
   collectStatistics(pkg, pkgPath)
   getExportedValue(pkg, name)   
}


#' Logs package identifying information
#'
#' \code{collectStatistics} retrieves package identifying information and
#' logs it
#'
#' @param pkgName the name of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @param pkgPath the full path of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @export
collectStatistics <-
function(pkgName, pkgPath) {

   # Need to use ::: because :: has been overloaded
   pkgVersion <- toString(utils:::packageVersion(pkgName))
   ownPackageName <- methods:::getPackageName()
   packageEnvPath <- paste("package", ownPackageName, sep=":")
   packageEnv <- as.environment(packageEnvPath)
   enableCollectionOption <- "package.stats.enabled"
   methodOption <- "package.stats.method"
   filterListOption <- "package.stats.filter"
   logDirOption <- "package.stats.logDirectory"
   logFilePrefixOption <- "package.stats.logFilePrefix"
   sessionLogFileOption <- "package.stats.sessionLogFile"
   suppressXaltWarningsOption <- "package.stats.suppress.xalt.warnings"
   csvLabels <- "ScriptFile,RVersion,PackageName,PackagePath,PackageVersion\n"

   filterList <- getOption(filterListOption)
   suppressXaltWarnings <- getOption(suppressXaltWarningsOption)

   # Set defaults here.  For some reason, these don't persist
   # when set in the initialize.R file.
   if (is.null(suppressXaltWarnings)) {
      options(package.stats.suppress.xalt.warnings = FALSE)
   }


   # Make sure needed options are set
   if (is.null(getOption(enableCollectionOption))) {
      stop(sprintf("%s: Option `%s` must be set to TRUE or FALSE",
         ownPackageName, enableCollectionOption))
   } else if (!(pkgName %in% filterList) &&
               (getOption(enableCollectionOption) == TRUE)) {

      # This section retains all packages loaded by the R application to
      # prevent redundant logging within the same R session.
      packageFrame <- utils:::getFromNamespace("package.stats.packageFrame",
         "packagestats")
      numberOfEntries <- nrow(packageFrame)
      indices <- which(packageFrame$PackageName == pkgName &
         packageFrame$PackageVersion == pkgVersion)
      
      if (length(indices) == 0) {
        #print("length(indices) == 0, no match, adding new entry")
        packageFrame[nrow(packageFrame)+1, ] <-
           list(pkgName, pkgVersion)
        utils:::assignInMyNamespace("package.stats.packageFrame", packageFrame)
      }
      
      # Print debug info here   
      #packageFrame <- utils:::getFromNamespace("package.stats.packageFrame", "packagestats")
      #print("package.stats.packageFrame after assign")
      #utils:::str(packageFrame)
   

      # If statistics collection is still active,
      # collect the needed information and save it to a log file or
      # pass it to XALT.

      # Call Sys.info to get user stats
      systemInfo <- Sys.info()
      processId <- Sys.getpid()
      timeStamp <- as.integer(Sys.time())

      argList <- commandArgs(trailingOnly=FALSE) 

      scriptFile <- "NA"

      # Find the name of the script file
      for (a in argList) {
         if (grepl("--file=", a)) {
            scriptFile <- substr(a, 8, nchar(a)) 
         }
      }

      # Get the R version
      rVersion <- paste(R.version$major, R.version$minor, sep=".")
      method <- getOption(methodOption)

      if (length(indices) == 0) {
         if (method == "csvfile") {
            writeCsvLogFile(ownPackageName, scriptFile,
               rVersion, pkgName, pkgPath, pkgVersion, systemInfo,
               logDirOption, logFilePrefixOption, sessionLogFileOption,
               processId, timeStamp, csvLabels)
         } else if (method == "xalt") {
 
            # Retrieve needed options relevant to XALT
            xalt_run_uuid_var <- getOption("package.stats.xalt_run_uuid_var")
            xalt_dir_var <- getOption("package.stats.xalt_dir_var")
            xalt_exec_path <- getOption("package.stats.xalt_exec_path")

            # Make sure that the needed options are set before proceeding
            if (is.null(xalt_run_uuid_var) || is.null(xalt_dir_var) ||
                is.null(xalt_exec_path)) {
               options(package.stats.enabled = FALSE)
               
               if (!suppressXaltWarnings) {
                  warning(sprintf("%s: xalt_run_uuid_var, xalt_dir_var, and xalt_exec_path options must be set when logging method is 'xalt'", ownPackageName))
               }
            } else { 
               xalt_run_uuid <- Sys.getenv(xalt_run_uuid_var)
               xalt_dir <- Sys.getenv(xalt_dir_var)

               if (xalt_run_uuid == "" || xalt_dir == "") {
                  if (!suppressXaltWarnings) {
                     warning(sprintf("%s: %s and %s environment variables must be set when logging method is 'xalt'", ownPackageName, xalt_run_uuid_var, xalt_dir_var))
                  }

                  options(package.stats.enabled = FALSE)
               } else {
                  # Construct input to system call to execute XALT package
                  # tracking utility
                  commandPath <- file.path(xalt_dir, xalt_exec_path)
                  commandArguments <- c("-u", xalt_run_uuid, "program", "R", "xalt_run_uuid", xalt_run_uuid, "package_name", pkgName, "package_version", pkgVersion, "package_path", pkgPath)

                  returnCode <- tryCatch({
                     system2(commandPath, args=commandArguments)
                  }, error = function(err) {
                     if (!suppressXaltWarnings) {
                        warning(err)
                     }
                  })

                  if (returnCode != "0") {
                     if (!suppressXaltWarnings) {
                        warning(sprintf("%s: XALT command '%s' exited with code %s", ownPackageName, xalt_exec_path, returnCode)) 
                     }
                  }
               
               }
            }
         } else {
            stop(sprintf("%s: Option %s is set to unsupported value `%s`\n"),
               ownPackageName, methodOption, method)        
         }
      }

   }

   #print("returning successfully from collectStatistics")
}


#' Writes package utilization information to a file in comma-separated value
#' (CSV) format.
#'
#' \code{writeCsvLogFile} performs logging of package utilization to a CSV log
#' file
#'
#' This function writes package utilization information to a file in
#' comma-separated value format.  The values currently saved to the CSV file
#' for each package entry are the following:
#' \describe{
#'   \item{ScriptFile}{the name of the R script file as returned by
#'      \code{\link[base]{commandArgs}} under the \code{--file} option, or the
#'      string "NA" if the session is interactive}
#'   \item{RVersion}{the version of the R programming environment}
#'   \item{PackageName}{the name of the package loaded}
#'   \item{PackageVersion}{the version of the package loaded}
#'   \item{UserLogin}{the user's login name as returned by \code{\link[base]{Sys.info}}}
#'   \item{UserName}{the real name of the user as returned by \code{\link[base]{Sys.info}}}
#'   \item{EffectiveUser}{the name of the effective user as returned by \code{\link[base]{Sys.info}}}
#' }
#'
#' @param ownPackageName the name of the package this function is a member of
#' @param scriptFile the name of the script file executed by Rscript or the
#'   empty string if R is being run interactively
#' @param rVersion the version of the R programming environment
#' @param pkgName the name of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @param pkgPath the path of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @param pkgVersion the version of the package that was loaded with a call to
#'    \code{\link[base]{library}} or \code{\link[base]{require}}
#' @param systemInfo the system information return by a call to
#'    \code{\link[base]{Sys.info}}
#' @param logDirOption the value of the option containing the log directory
#' @param logFilePrefixOption the value of the option containing the log file
#'    prefix that will appear in the log file name
#' @param sessionLogFileOption the value of the option containing the name
#'    of the session log file
#' @param processId the process ID of the R programming environment
#' @param timeStamp an integer POSIX timestamp
#' @param csvLabels the labels for each entry in the CSV log file
writeCsvLogFile <-
function(ownPackageName, scriptFile, rVersion, pkgName, pkgPath, pkgVersion,
        systemInfo, logDirOption, logFilePrefixOption, sessionLogFileOption,
        processId, timeStamp, csvLabels) {
   logDirectory <- getOption(logDirOption)
   logFilePrefix <- getOption(logFilePrefixOption)
   sessionLogFile <- getOption(sessionLogFileOption)

   # Check if the logging directory exists.
   # If not, disable the statistics collection.
   if (is.null(logFilePrefix) || is.null(logDirectory)) {
      warning(sprintf("%s: Options `%s` and `%s` must be set to enable logging package utilization statistics",
         ownPackageName, logFilePrefix, logDirectory))
      # Deactivate package statistics collection
      options(package.stats.enabled = FALSE)
      # Check existence of logging directory
   } else if (!dir.exists(logDirectory)) {
      warning(sprintf("%s: Package utilization statistics logging directory '%s' is not found.  Disabling package utilization statistics for this session.", ownPackageName, logDirectory))

      # Deactivate package statistics collection
      options(package.stats.enabled = FALSE)
   } else {
      if (is.null(sessionLogFile)) {
         sessionLogFile <- paste(logFilePrefix, systemInfo[["login"]],
            processId, timeStamp, sep="_")
         sessionLogFile <- paste(sessionLogFile, ".csv", sep="")
      }

      sessionLogFilePath <- file.path(logDirectory, sessionLogFile)

      fileExists <- file.exists(sessionLogFilePath)

      #print("checking if !fileExists")

      # If the log file does not exist for the current R session,
      # then create one.
      if (!fileExists) {
         fileCreated <- file.create(sessionLogFilePath)

         # Check if the file was created successfully.  If not,
         # then deactivate the statistics collection.
         if (fileCreated) {
            options(package.stats.sessionLogFile = sessionLogFile)
            cat(csvLabels, file=sessionLogFilePath, append=TRUE)
            fileExists <- TRUE
         } else {
            warning(sprintf("%s: Cannot create package utilization statistics log file '%s'.  Disabling package utilization statistics for this session.", ownPackageName, sessionLogFilePath))
            options(package.stats.enabled = FALSE)
         }
      }

      # If the file exists, write the needed information to the session
      # log file. 
      if (fileExists) {
         sep <- c(",", ",", ",", ",", "")
         #cat(sprintf("writeCsvLogFile pkgPath: %s\n", pkgPath))
         cat(scriptFile, rVersion, pkgName, pkgPath, pkgVersion,
            "\n", file=sessionLogFilePath, sep=sep, append=TRUE)
      }
   }
}


