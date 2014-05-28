#!/bin/bash -e
# VARIABLES PASSED FROM JENKINS:
# PYTHON build script
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
	wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz -O $SRC_DIR/$SOURCE_FILE
fi

tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
module add zlib


# pull in the built code for zlib
rm -rf $ZLIB_DIR
tar -xvzf /repo/$SITE/$OS/$ARCH/zlib/$ZLIB_VERSION/build.tar.gz -C /
./configure --prefix=$SOFT_DIR 
make -j 8
make check
make install DESTDIR=$WORKSPACE/build

# At this point, we should have built Python version

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
prereq ("zlib")
setenv        PYTHON_VERSION      $VERSION
#
#
#
setenv       PYTHON_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv 		 PYTHON_PATH          /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION/lib/
prepend-path LD_LIBRARY_PATH   $::env(PYTHON_DIR)/lib
MODULE_FILE
) > modules/$VERSION 

mkdir -p $LIBRARIES_MODULES/$NAME 
cp -v modules/$VERSION $LIBRARIES_MODULES/$NAME
module avail
