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
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
    mkdir -p $SRC_DIR
	wget http://www.hdfgroup.org/ftp/HDF5/current/src/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
fi

tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
module add zlib
module add openmpi

./configure --prefix=$SOFT_DIR 
make -j 8
make check
make install #DESTDIR=$WORKSPACE/build

# At this point, we should have built OpenMPI

ls -lht $SOFT_DIR


#mkdir -p $REPO_DIR
#tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE 


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
