#!/bin/bash -e
SOURCE_FILE=$NAME-$VERSION.tar.gz

module load ci
rm $SRC_DIR/$SOURCE_FILE
#module load gcc/4.8.2
echo "getting the file from gnu.org"
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
    mkdir -vp $SRC_DIR
	wget --verbose ftp://ftp.is.co.za/mirror/ftp.gnu.org/gnu/gsl/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
fi

ls -lht $SRC_DIR
ls -lht $SRC_DIR/$SOURCE_FILE
tar xvfz $SRC_DIR/$SOURCE_FILE -C $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
./configure --prefix $SOFT_DIR
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
setenv       GSL_VERSION       $VERSION
setenv       GSL_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(GSL_DIR)/lib
MODULE_FILE
) > modules/$VERSION 

mkdir -p $LIBRARIES_MODULES/$NAME 
cp modules/$VERSION $LIBRARIES_MODULES/$NAME 
