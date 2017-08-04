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
# vignettes tarred and compressed R package.
library(devtools)

devtools::load_all("/Users/jmccombs/projects/RWorkflowOptimization/source/library_overlay/packagestats", export_all=FALSE)

myEnv <- as.environment("package:packagestats")
print("ls():")
ls()
print("ls(envir=myEnv):")
ls(envir=myEnv)
library(cluster)
library(stats)
print("ls():")
ls()
print("ls(envir=myEnv):")
ls(envir=myEnv)

#print("str of package.stats.packageFrame")

#p <- get("package.stats.packageFrame", envir=myEnv)
#print("str of p")
#str(p)

#collectStatistics("cluster")
#print("after collectStatistics")
#p <- get("package.stats.packageFrame", envir=myEnv)
#print("str of p")
#str(p)


#x <- rbind(cbind(rnorm(10,0,0.5), rnorm(10,0,0.5)),
#           cbind(rnorm(15,5,0.5), rnorm(15,5,0.5)))
#pamx <- cluster::pam(x, 2)

