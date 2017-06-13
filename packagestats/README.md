# Introduction
The `packagestats` package collects package utilization statistics on packages
loaded using the `base::library` and `base::require` functions.  The package
works by overlaying the `base::library` and `base:require` functions with
identically named functions with the same function definitions which.  These
overlay functions save the names of the packages and other identifying
information to a session log file uniquely associated with the instance of the
R programming environment.

# Installation
The installation of the package can be trivially installed with the use of
the `install.packages` function.  However, the package must be loaded as
a default package at startup, and options must be set to inform the overlay
functions what directory to write the session log files to.

So that users transparently use the overlay functions, the `packagestats`
package must be loaded by default.  To accomplish this, the `Rprofile.site`
file should be modified to include `packagestats` as a package under the
`defaultPackages` option.  The following code accomplishes this when placed in
the site profile:

```
# Add packagestats to the list of default packages
p <- options("defaultPackages")
defaultPackages <- p$defaultPackages
defaultPackages <- c(defaultPackages, "cluster")
options("defaultPackages" = defaultPackages)
```

Options for activating the statistics collection, setting the logging directory,
and naming the session log files should also be set in the `Rprofile.site`
file.  The `package.stats.enabled`, `package.stats.logDirectory`,
and `package.stats.logFilePrefix` need to be set.  These options can be set
as follows:

```
# Enable the package statistics
options(package.stats.enabled = TRUE)
# Set the directory for the session pacakge utilization log files 
options(package.stats.logDirectory = "/path/to/log/files")
# Set the prefix of each log file name
options(package.stats.logFilePrefix = "rpkgstats") 
```
