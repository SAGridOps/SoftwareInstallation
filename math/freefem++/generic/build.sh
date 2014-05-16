#!/bin/bash
# The FreeFEM++ build script
# 
# FreeFEM has the possibility to download all the dependencies
module add ci

SOURCE_FILE=$NAME-$VERSION.tar.gz
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
	mkdir -p $SRC_DIR
	echo "getting the file"
	wget http://www.freefem.org/ff++/ftp/$SOURCE_FILE  -O $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
ls
cd freefem++-$VERSION
./configure --enable-download
time nice -n20 make -j2 install DESTDIR=$WORKSPACE/build

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
setenv       FREEFEM_VERSION       $VERSION
setenv       FREEFEM_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(FREEFEM_DIR)/lib
prepend-path PATH              $::env(FREEFEM_DIR)/bin
MODULE_FILE
) > modules/$VERSION 
# we need a new modules collection - Astro.
mkdir -p $LIBRARIES_MODULES/$NAME 
cp modules/$VERSION $LIBRARIES_MODULES/$NAME 
