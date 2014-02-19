#!/bin/bash -e
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
module load gmp/5.1.3
module load mpfr/3.1.2

rm -rf $GMP_DIR
tar -xvzf /repo/$SITE/$OS/$ARCH/gmp/$GMP_VERSION/build.tar.gz -C /

rm -rf $MPFR_DIR
tar -xvzf /repo/$SITE/$OS/$ARCH/mpfr/$MPFR_VERSION/build.tar.gz -C /

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
        mkdir -p $SRC_DIR
	wget http://mirror.ufs.ac.za/gnu/gnu/mpc/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
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
