SoftwareInstallation
====================

The installation scripts for SAGrid Application deployment. Note that 
these are not the applications themselves (they are kept in the 
"demo" directory), but the scripts necessary to download and compile 
the applications (and their dependencies) on the site's. This is 
typically done by the VO software administrator (sgmsagrid). 

## Repository organisation
This repository is organised into scientific domains, with 
application install scripts falling into one of them. Note that this 
characterisation is somewhat arbitrary, and follows no particular 
ontology - specifically because certain applications can be used for 
research across scientific domains - and is subject to change. 

### Compilers
There is a Compilers top-level directory

Apart from scientific domain directories, there is a top-level `tools` 
directory which contains generic tools and libraries which are often 
dependencies of specific applications. 

# Contributing
If you would like to see an application deployed on the infrastructure 
(for your own use, or to support a scientific community), please issue 
a pull request to the "proposed" branch. Once the proposed applications are successfully built on the SAGrid CI platform, they will be merged with the master branch.
