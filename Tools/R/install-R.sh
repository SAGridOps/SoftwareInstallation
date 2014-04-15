#!/bin/bash
# download the package

wget http://cran.r-project.org/src/base/R-3/R-3.1.0.tar.gz

tar xvfz R-3.1.0.tar.gz

cd R-3.1.0/
./configure --prefix=/opt/deploy/R/3.1.0 --with-x=no
nice -n20 make install
