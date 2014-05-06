#!/bin/bash -e
# VARIABLES PASSED FROM JENKINS:
# 
# 
# 
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
#module load gcc/4.8.2
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
    mkdir -p $SRC_DIR
	wget http://www.open-mpi.org/software/ompi/v1.8/downloads/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
fi

tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
./configure --prefix $SOFT_DIR
make -j 8
make check
make install DESTDIR=$WORKSPACE

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
setenv       openpmi_VERSION       $VERSION
setenv       openmpi_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(openmpi_DIR)/lib
prepend-path PATH			   $::env(openmpi_DIR)/bin
MODULE_FILE
) > modules/$VERSION 

mkdir -p $LIBRARIES_MODULES/$NAME 
cp modules/$VERSION $LIBRARIES_MODULES/$NAME
