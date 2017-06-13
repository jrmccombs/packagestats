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

# Run this script to generate/update the man pages from the roxygen
# comments, update the namespaces, and to perform validation checks on the
# package.  Use the generate_benchmark_package.R script to generate the 
# vignettes tarred and comparessed R package.
library(devtools)

packagePath <- file.path(getwd(), "packagestats")
devtools::document("packagestats")
devtools::check_built(packagePath, run_dont_test=TRUE)
readline(prompt="Press [ENTER] to continue")
