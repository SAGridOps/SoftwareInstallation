#!/bin/bash
wget http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz
tar xvfz argtable2-13.tar.gz
cd argtable2-13
./configure
make
echo "the build is finished"
echo "just kidding"
