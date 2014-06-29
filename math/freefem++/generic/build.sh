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
SOURCE_FILE=$NAME-$VERSION.tar.gz
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
	mkdir -vp $SRC_DIR
	echo "getting the file"
	wget http://www.freefem.org/ff++/ftp/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
else
      	tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
fi

## Now, proceed to build the application.
ls
cd freefem++-$VERSION
./configure --enable-download
time nice -n20 make -j2 install DESTDIR=$WORKSPACE/build

## The repo directory is where build artifact is kept - usually called
## build.tar.gz

## We update the artifact by creating the tarball in the $REPO_DIR 
## directory.
mkdir -p $REPO_DIR
rm -rf $REPO_DIR/* 
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo

## now, we have to make the modulefile for the application.
mkdir -p modules
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
# we need a new modules collection - Astro.
#mkdir -p $LIBRARIES_MODULES/$NAME 
mkdir -p $MATH_MODULES/$NAME
cp modules/$VERSION $MATH_MODULES/$NAME 
