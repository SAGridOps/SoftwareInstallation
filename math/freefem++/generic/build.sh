#!/bin/bash
# The FreeFEM++ build script
# 
# FreeFEM has the possibility to download all the dependencies

# Add the module for the build environment
# this will set up paths for the application artifact (build.tar.gz) as well as the directory in which to 
# cache the source file.
module add ci
# the $SRC_DIR may not be present in the first run, so we force it here. 
mkdir -vp $SRC_DIR
SOURCE_FILE=$NAME-$VERSION.tar.gz
# Check if the source file is available, if not, get it.
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
	echo "getting the file"
	wget http://www.freefem.org/ff++/ftp/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
else
      	echo "$SRC_FILE is already here"
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

mkdir -p $REPO_DIR
rm -rf $REPO_DIR/* 
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo

# we need to make a few modules for the application :
# 1. the ci build module
# 2. the module that will be used by CVMFS clients
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
setenv       FREEFEM_DIR       
prepend-path LD_LIBRARY_PATH   $::env(FREEFEM_DIR)/lib
prepend-path PATH              $::env(FREEFEM_DIR)/bin
MODULE_FILE
) > modules/$VERSION 
# w
mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME 

# We need to make a CVMFS modulefile as well
