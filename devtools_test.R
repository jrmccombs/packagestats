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

options(package.stats.enabled = TRUE)
#options(package.stats.method = "xalt")
options(package.stats.method = "csvfile")
options(package.stats.filter = c("base"))
options(package.stats.logDirectory = "/Users/jmccombs/projects/RWorkflowOptimization/source/library_overlay/log")
options(package.stats.logFilePrefix = "rpkgstats")
options(package.stats.xalt_run_uuid_var = "XALT_RUN_UUID")
options(package.stats.xalt_dir_var = "XALT_DIR")
options(package.stats.xalt_exec_path = "libexec/xalt_record_pkg")

library(devtools)

devtools::load_all(pkg="packagestats")

# Should not add any log entry because both package and help have been set
library(package=cluster,help=cluster)
# Should not add any log entry because help has been set
library(help=cluster)
# Should add a log entry
library(package=cluster)
# Should not add a log entry because it is in the filter list
library(base)
# Should add a log entry
library(cluster)
# Should add a log entry
library(stats)

