---
Category: Documentation
Description: This document describes to new users how to write a script that will execute the build phase of their project or application, in the Jenkins instance at http://ci.sagrid.ac.za:8080
Tags:
  - Documentation
  - Build
License: Apache
Copyright:
  - Author: [Bruce Becker, Fanie Riekert]
  - Institute: [CSIR Meraka Institute, University of the Free State]
---

# The build script

This document will give you a quick idea of how to create a build script, and what scaffolding and support Jenkins will give you.

# General

We suggest that all build scripts take the following general structure:

  1. Setup environment, select dependencies
  2. Obtain source
  3. Compile
  4. Create modulefile

## Fail-fast fail-often

It is good practice to ["fail-fast"](http://en.wikipedia.org/wiki/Fail-fast) when writing build scripts. Along with this, use a ["fail-often"] approach, to throw errors at each point in the above list. This will help the admins and yourself communicate as to where the problem is and what can be done about it.

## Environment and Variables

Jenkins jobs have been configured with certain *'axes'* which become environment variables in the job's shell.
These are :

| Name | Description | Example |
|:----:|:-----------:|:-------:|
| `$NAME` | The name of the project - should be similar or the same as the name of the source code tarball | `gmp` |
| `$VERSION` | Version of the package you are requesting | `5.1.3` |
| `$SITE` | The "site" flavour that you are building for. Currently only generic sites are supported. | `generic` |
| `$ARCH` | The target architecture. Only `x86_64` is currently supported | `x86_64` |
| `$OS` | The target operating system. Only `SL6` (CentOS 6) and `u1404` (Ubuntu Linux 14.04) are currently supported |

Furthermore, a build environment is provided by the `ci` module on the build slaves. These provide you with the following variables:

| Name | Description | Example or value |
|:----:|:-----------:|:-------:|
| `$SRC_DIR` | The directory that the source file will be downloaded into. It is used as a local cache | `/repo/src/$NAME/VERSION` |
| `$REPO_DIR` | Directory into which compiled artifacts are staged | `/repo/$SITE/$OS/$ARCH/$NAME/$VERSION/build.tar.gz` |
| `$SOFT_DIR` | Mount path of the actual software repo containing the applications | `/apprepo/$SITE/$OS/$NAME/$VERSION` |

## Modules

Modulefiles are organised according to the scientific domain that the application falls in and are kept under
```
/repo/modules/
```
The following have been provided already, feel free to propose new ones:

  * `LIBRARIES_MODULES=/repo/modules/libraries`
  * `LANGUAGES_MODULES=/repo/modules/languages`
  * `BIOINFORMATICS_MODULES=/repo/modules/bioinformatics`
  * `PHYSICAL_MODULES=/repo/modules/physical-sciences`
  * `COMPILERS_MODULES=/repo/modules/compilers`


# Example

## Setup Environment

Below we give the example of a build script for [mpc]
```


```
