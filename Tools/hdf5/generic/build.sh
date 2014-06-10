#!/bin/bash -e
# VARIABLES PASSED FROM JENKINS:
# 
# 
# 
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
echo $SOFT_DIR
echo $WORKSPACE
echo $SRC_DIR
echo $NAME
echo $VERSION
#module load gcc/4.8.2
if [[ ! -s $SRC_DIR/$SOURCE_FILE ]]
then
    echo "getting the file from the web"
    mkdir -p $SRC_DIR
    wget http://www.hdfgroup.org/ftp/HDF5/releases/$NAME-$VERSION/src/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE 
else
   echo "the file is local, untarring it"
   ls -lht $SRC_DIR/$SOURCE_FILE
   tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
fi

ls $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
module add zlib
module add openmpi

# pull in the built code for zlib
rm -rf $ZLIB_DIR
tar -xvzf /repo/$SITE/$OS/$ARCH/zlib/$ZLIB_VERSION/build.tar.gz -C /
# ... and openmpi

rm -rf $OPENMPI_DIR
tar xvfz /repo/$SITE/$OS/$ARCH/openmpi/$OPENMPI_VERSION/build.tar.gz -C /

./configure --prefix=$SOFT_DIR 
make -j 8
make check
make install DESTDIR=$WORKSPACE/build

# At this point, we should have built OpenMPI

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
module load zlib openmpi
prereq zlib 
prereq openmpi
setenv       HDF5_VERSION       $VERSION
#
#
#
setenv       HDF5_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(HDF5_DIR)/lib
MODULE_FILE
) > modules/$VERSION 

mkdir -p $LIBRARIES_MODULES/$NAME 
cp -v modules/$VERSION $LIBRARIES_MODULES/$NAME
module avail
