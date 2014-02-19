#!/bin/bash
## Name of Application: Abyss 
## Application Maintainer: Timothy Carr
## VO: SAGrid
## Date: 06 September 2011 

LCG_GFAL_INFOSYS=srvslngrd001.uct.ac.za
LFC_HOST=devslngrd002.uct.ac.za
LFC_TYPE=lfc
ABYSS_VER="1.2.7"
GOOGLESPARSE_VER="1.11"
# using VO_SAGRID_SW_DIR as /tmp for now. 
VO_SAGRID_SW_DIR=/tmp

export LFC_HOST LFC_TYPE
whoami 

# create the download directory
# get the list of packages from the pkg directory and download all of them
mkdir -vp $HOME/download
PKGS=`lfc-ls /grid/sagrid/software/abyss/`
for pkg in $PKGS ; do 
	lcg-cp -v lfn:/grid/sagrid/software/abyss/$pkg $HOME/download/$pkg
done

# Uncompress data and compile 
# Dependencies first then the main application install. 

for f in $HOME/download/*.tar.gz;do tar xfvz "$f" -C $HOME/download; done
cd $HOME/download/sparsehash-$GOOGLESPARSE_VER
./configure --prefix=$VO_SAGRID_SW_DIR/abyss-$ABYSS_VER/sparsehash-$GOOGLESPARSE_VER
make 
make install

cd $HOME/download/abyss-$ABYSS_VER
./configure --prefix=$VO_SAGRID_SW_DIR/abyss-1.2.7 --with-mpi=/usr/lib64/openmpi CPPFLAGS=-I$VO_SAGRID_SW_DIR/abyss-1.2.7/sparsehash-1.11/include

make AM_CXXFLAGS=-Wall
make install

# Clean Up 
rm -rf $HOME/download

rm -rf $VO_SAGRID_SW_DIR

