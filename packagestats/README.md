# Introduction
The `packagestats` package collects package utilization statistics on packages
loaded and attached using the `base::library` and `base::require` functions.
The package works by implementing `library` and `require` functions with identical
interfaces that appear in the search path of attached packages before the
`base` package so that the utilization statistics can be collected
transparently to the user.  The names of the packages and other identifying
information are logged and uniquely associated with the instance of the
R programming environment so that system administrators and developers can
study software utilization and prioritize development efforts.

# Installation
The installation of the package can be trivially installed with the use of
the `install.packages` function.  The package must be loaded as a default
package at startup, and options must be set to configure the logging
functionality.

So that users transparently use the `packagestats` functions, the `packagestats`
package must be loaded by default.  To accomplish this, the `Rprofile.site`
file (usually found under the /etc directory of the R installation) containing
the site profile should be modified to include `packagestats` as a package
under the `defaultPackages` option.  The following code accomplishes this when
placed in the site profile:

```
# Add packagestats to the list of default packages
p <- options("defaultPackages")
defaultPackages <- p$defaultPackages
defaultPackages <- c("packagestats", defaultPackages)
options("defaultPackages" = defaultPackages)
```

The package utilization information can be written to a CSV log file or
performed using the XALT utility.  Options for activating the statistics
collection, setting the logging method, and specifying other logging options
should be set in the `Rprofile.site` file common to all R installations.  All
package options should be set in the `Rprofile.site` file.  The
`package.stats.enabled` and `package.stats.method` options must be set to
enable/disable the logging and select the logging method, respectively.

## Enabling CSV logging
The CSV log file method is implemented jointly by the `packagestats` package
and a C-language utility that performs the actual creation and appending of
the log file.  This utility is needed so that R users do not need access
permissions to the logging directory; the set-user-ID and set-group-ID bits
can be set on the utility so that it has compatible read and write permissions
with the logging directory.

To use the CSV file logging method, the logging method is set to `csvfile`,
then the `package.stats.sessionLogFile` option is used to name the log file to
be used.  If the `package.stats.sessionLogFile` option is unset, then the option
`package.stats.logFilePrefix` must be set and the log file will
be constructed according to the form
`logFilePrefix_login_procesId_timeStamp.csv` where `logFilePrefix` is as an
arbitrary string given by the option discussed above, `login` is the user
login ID, `processId` is the process ID of the R session, and `timeStamp`
is the system time converted to an integer using `as.integer(Sys.time())`.
The following example shows how to enable and configure collection of
package utilization using CSV log files with the option
`package.stats.sessionLogFile` unset:

```
# Enable the package statistics
options(package.stats.enabled = TRUE)
# Set the logging method to CSV files
options(package.stats.method = "csvfile")
# Set the prefix of each log file name
options(package.stats.logFilePrefix = "rpkgstats") 
# Set the path to the C-language log file writer utility
options(package.stats.logWriter = "/full/path/to/logwriter")
```

The following information is currently saved in the CSV log file created for
each R session:
1. __ScriptFile__ the name of the R script file as returned by
   `commandArgs` under the `--file` option, or the string "NA" if the session
   is interactive
1. __RVersion__ the version of the R programming environment
1. __PackageName__ the name of the package loaded
1. __PackagePath__ the full path to the R package loaded
1. __PackageVersion__ the version of the package loaded

The user login ID is not saved in the file, as it is already part of the log
file name.

### Building the log file writer utility
The Make files and source code for the utility reside in the `log_writer` 
directory that resides parallel to the R package source for this package.
Edit the `Makefile.inc` file and set the wanted compilers and other
utilities for building the executable utility, and set the `LOGDIR`
environment variable to the full path of the directory where the R session
log files are to be stored.  The directory path is hardcoded in the
executable for security so that only the logging directory can be
written to.  Type `make all` to make both the debug and release versions, which
will reside in the `debug` and `release` subdirectories created by the Make
file.  Copy the release version of the executable from the `release`
subdirectory to its desired location.  Change the owner and group permissions
to the account and group suitable for maintaining the log directory, then
set the set-user-ID and set-group-ID so that the user and group permissions
on the created log files will have the same user and group IDs of the
log writer utility.


## Enabling XALT logging
To utilize the XALT utility, `package.stats.method` should be set to `xalt` and
the `package.stats.xalt_run_uuid_var`, `package.stats.xalt_dir_var`, and
`package.stats.xalt_exec_path` options should be set.  The
`package.stats.xalt_run_uuid_var` option specifies the XALT environment variable
containing the UUID generated by XALT for the R session, the
`package.stats.xalt_dir_var` option specifies the XALT environment variable
containing the path to the XALT installation being used, and the
`package.stats.xalt_exec_path` option specifies the relative path starting from
the directory specified by the environment variable given by
`package.stats.xalt_dir_var` to the XALT executable utility for logging R
package utilization.  The `packages.stats.suppress.xalt.warnings`, which
is set to `FALSE` by default, can be used to prevent display of warnings in
R output when XALT logging has been disabled on the XALT side.

```
# Enable the package statistics
options(package.stats.enabled = TRUE)
# Set the logging method to use XALT
options(package.stats.method = "xalt")
# Set the XALT environment variable specifying the UUID of the R session
options(package.stats.xalt_run_uuid_var = "XALT_RUN_UUID")
# Set the directory path to the XALT installation being used
options(package.stats.xalt_dir_var = "XALT_DIR")
# Set the relative path to the XALT package logging utility
options(package.stats.xalt_exec_path = "libexec/xalt_record_pkg")
# Prevent logging of XALT warning messages
options(package.stats.suppress.xalt.warnings = TRUE)
```

A filter list option `package.stats.filter` should also be set to a vector of
strings specifying packages that are to be exempted from utilization tracking,
or `NULL` if none are to be exempted.  Also, to avoid tracking packages loaded
by default, the filter list should be composed of the `defaultPackages` option
list and any additional names of packages to be filtered; an example of how
to do this is given below.

```
# Filter default packages and any additional packages you want
# filtered.
options(package.stats.filter = c(defaultPackages, "base"))
```

Packages referenced using the `::` operator during
function calls also trigger logging of the associated package
(if not a member of the filter list) because that operator is overloaded to
perform logging with `packagestats`.

