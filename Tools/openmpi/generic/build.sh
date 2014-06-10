#!/bin/bash -e
# VARIABLES PASSED FROM JENKINS:
# 
# 
# 
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
echo "SOFT DIR = $SOFT_DIR"
echo "WORKSPACE = $WORKSPACE"
echo "SRC DIR = $SRC_DIR"
echo "REPO DIR = $REPO_DIR"
ls -lht $SRC_DIR
#module load gcc/4.8.2

echo "where is the code ?"
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
    echo "Not available locally, downloading"
    mkdir -p $SRC_DIR
    wget http://www.open-mpi.org/software/ompi/v1.8/downloads/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
else 
    echo "the code is already here, untarring"
    tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
fi

cd $WORKSPACE/$NAME-$VERSION
./configure --prefix=$SOFT_DIR
make -j 8
make check
make install # DESTDIR=$WORKSPACE/build

# At this point, we should have built OpenMPI

ls -lht $SOFT_DIR

rm -rf $REPO_DIR/* 
mkdir -p $REPO_DIR
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
setenv       OPENMPI_VERSION       $VERSION
#
#
#
setenv       OPENMPI_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(OPENMPI_DIR)/lib
prepend-path PATH			   $::env(OPENMPI_DIR)/bin
MODULE_FILE
) > modules/$VERSION 

mkdir -p $LIBRARIES_MODULES/$NAME 
cp -v modules/$VERSION $LIBRARIES_MODULES/$NAME

module avail
module add openmpi
which mpicc
