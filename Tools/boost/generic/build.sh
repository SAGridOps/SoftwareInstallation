#!/bin/bash
###############################################
# Africa-Arabia Regional Operations Centre
# Copyright CSIR Meraka Institute 2013-2015
# Title                   : build.sh
# First Author            : Bruce Becker
# Institute               : CSIR Meraka Institute
###############################################
#
# Short Description
# The build script for the BOOST C++ libraries
# See http://www.boost.org
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
  wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download -O $SRC_DIR/$SOURCE_FILE
fi
tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
tar xvfz boost-1.55.0.tar.gz
cd boost_1_55_0
./bootstrap.sh --prefix=$SOFT_DIR
./b2 -d+2 stage threading=multi link=shared
./b2 install
