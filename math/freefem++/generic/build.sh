#!/bin/bash
# The FreeFEM++ build script
# 
# FreeFEM has the possibility to download all the dependencies


#######################################################################
## Add the CI module
##
## The CI module provides environment variables for different
## architectures and operating systems, with paths to the source
## and build directories of the application
## It does not have dependencies built into it

module add ci
## If you need dependencies, add the repo module and then add the modules
## which you need for the dependencies
# module add repo

## Download the source package from the remote location
## This is usually the internet; the project page, repo or some 3rd 
## party repo such as sourceforge. 


## Since we only need to download the package the first time, we check
## if there is the tarball already locally available. If so, we untar it
## if not, get it and put it in the directory containing the source files

## The package should be unpacked into the workspace owned by jenkins
=======
# Add the module for the build environment
# this will set up paths for the application artifact (build.tar.gz) as well as the directory in which to 
# cache the source file.
echo "PATH is $PATH"
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
module add ci
echo "added ci"
module avail
echo "PATH is $PATH"
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
module add gcc/4.8.2
echo "added gcc"
echo "PATH is $PATH"
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
module add openmpi/1.8.1
echo "added openmpi"
echo "PATH is $PATH"
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"

# the $SRC_DIR may not be present in the first run, so we force it here. 
mkdir -vp $SRC_DIR

SOURCE_FILE=$NAME-$VERSION.tar.gz
# Check if the source file is available, if not, get it.
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
	mkdir -vp $SRC_DIR
	echo "getting the file"
	wget http://www.freefem.org/ff++/ftp/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
else
      	tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
fi
# We untar it into the working directory of the job.

tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls
cd freefem++-$VERSION
./configure --enable-download
download/getall -a 
# we don't want to have paralellism, because independent threads will die sometimes
time make -j4
time make -j4
# At this point, the compiliation should either pass or fail. If the compilation passes, we should continue, else exit the script.
# The application is installed in $WORKSPACE/build

time nice -n20 make install DESTDIR=$WORKSPACE/build
echo ""
echo "looks like the build was ok, let's check the actual build"
make check

## The repo directory is where build artifact is kept - usually called
## build.tar.gz

## We update the artifact by creating the tarball in the $REPO_DIR 
## directory.
mkdir -p $REPO_DIR
rm -rf $REPO_DIR/* 
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo

echo "making the module file for the build system"

# we need to make a few modules for the application :
# 1. the ci build module
# 2. the module that will be used by CVMFS clients
mkdir -p modules
(
cat <<MODULE_FILE
%Module1.0
# $NAME modulefile
#
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       FREEFEM_VERSION       $VERSION
setenv       FREEFEM_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(FREEFEM_DIR)/lib
prepend-path PATH              $::env(FREEFEM_DIR)/bin
MODULE_FILE
) > modules/$VERSION 
# w
mkdir -p $MATH_MODULES/$NAME
cp modules/$VERSION $MATH_MODULES/$NAME 


# We need to make a CVMFS modulefile as well
echo "making the module file for the execution environment"
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       FREEFEM_VERSION       $VERSION
setenv       FREEFEM_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(FREEFEM_DIR)/lib
prepend-path PATH              $::env(FREEFEM_DIR)/bin
MODULE_FILE
) > modules/$VERSION 
cp modules/$VERSION $MODULES/$NAME 
