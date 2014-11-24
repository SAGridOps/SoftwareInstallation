#!/bin/bash -e
###############################################
# Africa-Arabia Regional Operations Centre
# This source code is under the copyright of CSIR Meraka
# Title                   : build.sh
# First Author            : Bruce Becker
# Institute               : CSIR Meraka Institute
###############################################
#
# This is the build script for the boost C++ libraries.
# See http://www.boost.org/
#
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
# Load other modules here if you need to.
module load gcc

# This will go away when we have NFS
rm -rf $GCC_DIR
# Pull in the build artifact for GCC
tar -xvzf /repo/$SITE/$OS/$ARCH/gcc/$GCC_VERSION/build.tar.gz -C /
# And the dependencies
rm -rf $MPFR_DIR
tar -xvzf /repo/$SITE/$OS/$ARCH/mpfr/$MPFR_VERSION/build.tar.gz -C /
rm -rf $MPC_DIR
tar xvfz /repo/$SITE/$OS/$ARCH/mpc/$MPC_VERSION/build.tar.gz -C /

###############################################################################
# Get the source code if we don't already have it
###############################################################################
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
        mkdir -p $SRC_DIR
	wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download -O boost-1.55.0.tar.gz  -O $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
./configure --prefix $SOFT_DIR --with-gmp=$GMP_DIR --with-mpfr=$MPFR_DIR
make -j 8
make check
make install DESTDIR=$WORKSPACE/build

mkdir -p $REPO_DIR
rm -rf $REPO_DIR/*
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo

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

module load gmp/$GMP_VERSION
module load mpfr/$MPFR_VERSION

setenv       MPC_VERSION     $VERSION
setenv       MPC_DIR         /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(MPC_DIR)/lib
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME
