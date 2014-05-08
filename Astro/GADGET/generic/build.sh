#!/bin/bash
# The GADGET-2 build script
# 
# GADGET requires HDF5 FFTW2 ZLIB and openmpi
module add ci
module add fftw/2.1.5
module add hdf5
module add openmpi
module add gsl

ls -lht  $GSL_DIR/include
ls -lht $GSL_DIR/include/gsl
find $GSL_DIR/include -name "gsl_rng.h"
# GADGET comes with a Make file which needs to be tweaked in order to compile 
# for a specific architecture/system.
# this is kept in the repo which is checked out before compiling.
MAKEFILE=/repo/scripts/Astro/$NAME/$SITE/Makefile.works
echo "Make file is $MAKEFILE"
# we need to convert the capital name to the lower case.
echo "NAME is $NAME - converting to lower case"
# NAME=${NAME,,} # this does not work on Jenkins - maybe wrong bash version
NAME=`echo "$NAME" | tr '[:upper:]' '[:lower:]'`
echo "NAME is now $NAME"
SOURCE_FILE=$NAME-$VERSION.tar.gz
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
	mkdir -p $SRC_DIR
	echo "getting http://www.mpa-garching.mpg.de/gadget/$SOURCE_FILE"
	wget http://www.mpa-garching.mpg.de/gadget/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls $WORKSPACE
# gadget directory doens't follow our nice naming conventions so
# we need to capitalise the first letter
# cp Makefile.works $WORKSPACE/${NAME^}-$VERSION/Gadget2/Makefile
# apparently bash on the build machines is still 3.x

NAME=`echo ${NAME:0:1} | tr  '[a-z]' '[A-Z]'`${NAME:1}
DIR=$PWD
cd $WORKSPACE/$NAME-$VERSION/Gadget2
cp -fv $MAKEFILE Makefile
make

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
preqreq("gsl","fftw/2.1.5","hdf5")
module-whatis   "$NAME $VERSION."
setenv       GSL_VERSION       $VERSION
setenv       GSL_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(GSL_DIR)/lib
MODULE_FILE
) > modules/$VERSION 
# we need a new modules collection - Astro.
mkdir -p $LIBRARIES_MODULES/$NAME 
cp modules/$VERSION $LIBRARIES_MODULES/$NAME 


