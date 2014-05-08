#!/bin/bash -e
# The GADGET-2 build script
# 
# GADGET requires HDF5 FFTW2 ZLIB and openmpi
modeul add ci
module add fftw/2.1.5
module add hdf5
module add openmpi
module add gsl

# GADGET comes with a Make file which needs to be tweaked in order to compile 
# for a specific architecture/system.
# this is kept in the repo which is checked out before compiling.
ls -lht # should show Makefile.works

SOURCE_FILE=$NAME-$VERSION.tar.gz
#if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
mkdir -p $SRC_DIR
echo "getting http://www.mpa-garching.mpg.de/gadget/$SOURCE_FILE"
wget http://www.mpa-garching.mpg.de/gadget/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
#fi

tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls $WORKSPACE
# gadget directory doens't follow our nice naming conventions so
# we need to capitalise the first letter
cp Makefile.works $WORKSPACE/${NAME^}-$VERSION/Gadget2/Makefile
cd $WORKSPACE/${NAME^}-$VERSION/Gadget2
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


