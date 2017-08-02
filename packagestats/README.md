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
file should be modified to include `packagestats` as a package under the
`defaultPackages` option.  The following code accomplishes this when placed in
the site profile:

```
# Add packagestats to the list of default packages
p <- options("defaultPackages")
defaultPackages <- p$defaultPackages
defaultPackages <- c("packagestats", defaultpackages)
options("defaultPackages" = defaultPackages)
```

Options for activating the statistics collection, setting the logging directory,
and naming the session log files should also be set in the `Rprofile.site`
file.  The `package.stats.enabled` and `package.stats.method` options must be
set to enable/disable the logging and select the logging method, respectively.
If the logging method is set to `csvfile`, then the
`package.stats.logDirectory` must be set to the the directory where the
CSV log files are to be saved and the `package.stats.logFilePrefix` option must also
be set to a prefix string to be added to the log file name.  For example, to
enable collection of utilization statistics using CSV log files, the following
settings are valid:

```
# Enable the package statistics
options(package.stats.enabled = TRUE)
# Set the logging method to CSV files
options(package.stats.method = "csvfile")
# Set the directory for the session pacakge utilization log files 
options(package.stats.logDirectory = "/path/to/log/files")
# Set the prefix of each log file name
options(package.stats.logFilePrefix = "rpkgstats") 
```

The following information is currently saved in the CSV log file created for
each R session:
1. __ScriptFile__ the name of the R script file as returned by
   `commandArgs` under the `--file` option, or the empty string if the session
   is interactive
1. __RVersion__ the version of the R programming environment
1. __PackageName__ the name of the package loaded
1. __PackageVersion__ the version of the package loaded
1. __UserLogin__ the user's login name as returned by `base::Sys.info`
1. __UserName__ the real name of the user as returned by `base::Sys.info`
1. __EffectiveUser__ the name of the effective user as returned by
   `base::Sys.info`

A filter list option `package.stats.filter` should also be set to a vector of
strings specifying packages that are to be exempted from utilization tracking, or
`NULL` if none are to be exempted.
Also, packages loaded by default by the R programming environment upon
initialization, are not currently tracked by the `packagestats` package.  This is
because those packages are loaded before `packagestats`.  However,
packages referenced using the `::` operator during function calls cause logging
of the associated package (if not a member of the filter list) because that
operator is overloaded to perform logging with `packagestats`.


