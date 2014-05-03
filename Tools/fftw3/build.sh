#!/bin/bash
# there are two build modes

if [ MODE == 'git' ] ; then 
    git clone https://github.com/FFTW/fftw3.git
    cd fftw3
    ./bootstrap.sh
# from git repo need to enable maintainer mode
    ./configure --enable-mpi --enable-openmp  --enable-maintainer-mode --prefix=/opt/deploy/fftw3/3.4.4
    nice -n20 make 
elif [ MODE == 'tarball' ] ; then 
    wget http://www.fftw.org/fftw-3.3.4.tar.gz
    tar xvfz fftw-3.3.4.tar.gz
    cd fftw-3.3.4
    ./configure --enable-mpi --enable-openmp  --enable-maintainer-mode --enable-float --prefix=/opt/deploy/fftw3/3.4.4
    nice -n20 make 
    make install
fi

tests/bench 10000000
# takes a long time
# Problem: 10000000, setup: 2654.10 s, time: 342.93 ms, ``mflops'': 3390.4
# on my laptop

# run the benchmarks
# This is failing to cause ticket 7
if [ $TEST ] ; then
    cd ../
    wget http://www.fftw.org/benchfft/benchfft-3.1.tar.gz
    tar xvfz benchfit-3.1.tar.gz
    ./configure LDFLAGS=-L/opt/deploy/fftw3/3.3.4/lib
    nice -n20 make -j4
fi

