#!/bin/bash 
#  This only gets run after build.sh

CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)

module load ci
module load gmp/5.1.3
module load mpfr/3.1.2
module load mpc/1.0.1
module load gcc/$VERSION

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
        mkdir -p $SRC_DIR
	wget http://mirror.ufs.ac.za/gnu/gnu/gcc/gcc-$VERSION/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE

cd $WORKSPACE/$NAME-$VERSION
./configure --prefix=$SOFT_DIR --with-gmp=$GMP_DIR --with-mpfr=$MPFR_DIR \
        --with-mpc=$MPC_DIR --enable-languages=c,c++,fortran,java --disable-multilib

make -j $CPUS
#make check
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
        puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis   "Sets the environment for using $NAME ($VERSION.)"

module load gmp/$GMP_VERSION
module load mpfr/$MPFR_VERSION
module load mpc/$MPC_VERSION

setenv     GCC_VERSION    $VERSION
set        GCC_DIR        /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION

prepend-path    PATH            \$GCC_DIR/include
prepend-path    PATH            \$GCC_DIR/bin
prepend-path    MANPATH         \$GCC_DIR/man
prepend-path    LD_LIBRARY_PATH \$GCC_DIR/lib
prepend-path    LD_LIBRARY_PATH \$GCC_DIR/lib64

setenv          CC              \$GCC_DIR/bin/gcc
setenv          GCC             \$GCC_DIR/bin/gcc
setenv          FC              \$GCC_DIR/bin/gfortran
setenv          F77             \$GCC_DIR/bin/gfortran
setenv          F90             \$GCC_DIR/bin/gfortran
MODULE_FILE
) > modules/$VERSION 

mkdir -p $COMPILERS_MODULES/$NAME 
cp modules/$VERSION $COMPILERS_MODULES/$NAME
