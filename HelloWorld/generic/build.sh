#!/bin/bash -e

# This is a trivial example of a build script for the CI environment

# The build script consists of a few standard steps:
# 1. Load the CI module
# 2.1 Pull in source code from repo or web url
# 2.2 Create build directory
# 3. Configure && build
# 4. Create and copy new modulefile


module load ci
