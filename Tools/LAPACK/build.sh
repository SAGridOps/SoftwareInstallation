#!/bin/bash
wget http://www.netlib.org/lapack/lapack-3.5.0.tgz
wget http://www.netlib.org/blas/blas.tgz
WORKDIR=$PWD
tar xvfz lapack-3.5.0.tgz
cd lapack-3.5.0
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/opt/deploy/lapack/3.5.0
nice -n20 make -j4 install