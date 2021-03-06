[![Stories in Ready](https://badge.waffle.io/sagridops/softwareinstallation.png?label=ready&title=Ready)](https://waffle.io/sagridops/softwareinstallation)
SoftwareInstallation
====================
<!---
[![Build Status](http://ci.sagrid.ac.za:8080/job/SAGrid%20Application%20Repo/badge/icon)](http://ci.sagrid.ac.za:8080/job/SAGrid%20Application%20Repo/)
--->
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.10233.png)](https://zenodo.org/record/10233?ln=en)

This repo contains the installation scripts for SAGrid Application deployment. Note that
these are not the applications themselves (they are kept in the
"demo" directory), but the scripts necessary to download and compile
the applications (and their dependencies) on the site's. This is
typically done by the VO software administrator (sgmsagrid).

# Adding new applications

If you want to propose a new application for the repo, please see [wiki/Porting](the Porting wiki page).  A continuous integration platform is used to help you understand what needs to be done.

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

### Tools
Tools are usually common dependencies which are not found on the WN

# Contributing
If you would like to see an application deployed on the infrastructure
(for your own use, or to support a scientific community), please issue
a pull request to the "proposed" branch. Once the proposed applications are successfully built on the SAGrid CI platform, they will be merged with the master branch.

# Scrum
[![Stories in Ready](https://badge.waffle.io/sagridops/softwareinstallation.png?label=ready&title=Ready)](https://waffle.io/sagridops/softwareinstallation)
