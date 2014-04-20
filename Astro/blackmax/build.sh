#!/bin/bash
wget http://www.hepforge.org/archive/blackmax/BlackMax-2.02.0.tar.gz
tar xvfz BlackMax-2.02.0.tar.gz
cd blackmax
make BlackMaxOnly
# tests
./BlackMax

# keep the output
mv BlackMax BlackMaxOnly 
mv output.txt output-blackmaxonly.txt

# make the LHAPDF version
make BlackMax
# This has to be set in the shell, for some strange reason
export LHAPDF=/opt/deploy/lhapdf/6.0.5/share/LHAPDF
# you need to change the variable of the pdf set used to 
# should be something like a awk s/something/g here.
# or we can use a different parameters file
./BlackMax

# keep the output
mv BlackMax BlackMaxLHAPDF
mv output.txt output-blackmaxlhapdf.txt


# Build the pythia version
make 

