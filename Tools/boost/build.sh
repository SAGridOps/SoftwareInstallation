#!/bin/bash
wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download -O boost-1.55.0.tar.gz 
tar xvfz boost-1.55.0.tar.gz
cd boost_1_55_0
./bootstrap.sh --prefix=/opt/deploy/boost/1.55.0
./b2 -d+2 stage threading=multi link=shared
./b2 install