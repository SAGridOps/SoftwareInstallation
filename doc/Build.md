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
| `$WORKSPACE` | The directory which Jenkins uses to run the jobs in | `/var/lib/jenkins/job-name`
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
Below we give the example of a build script for the [GNU Multiprecision Library - mpc](http://www.multiprecision.org/).

## Setup Environment

```bash
#!/bin/bash -e
SOURCE_FILE=$NAME-$VERSION.tar.gz
module load ci
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR
```

In this initial stanza, we :

  1. Define the source file based on the name and version of the package we are building (these come from the Jenkins job)
  2. Load the Continuous Integration module, which provides us with the repo, cache and workspace
  3. Create the directories that this new project will be using (with `-p` - if they haven't been already created, they will be created)

## Obtain the code

```bash
if [[ ! -e $SRC_DIR/$SOURCE_FILE ]]
then
        mkdir -p $SRC_DIR
  wget http://mirror.ufs.ac.za/gnu/gnu/gmp/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
else
   tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
fi
```
Next, we obtain the source code. This is  usually from a repo or web address. Since we don't want to do this every time a build runs, we check of the cache is present first; if so, we use that.

In the case of scm repos, this could be a simple `git pull`, `svn update` etc.

## Build the code

```bash
cd $WORKSPACE/$NAME-$VERSION
./configure --prefix $SOFT_DIR
make -j 8
make check
make install DESTDIR=$WORKSPACE/build
```

Here is the meat of the script. Depending on the application, there will be different procedures for compiling or installing the application. In the majority of cases, open source projects rely on some form of *configure* &#10140; *compile* procedure.  <!-- define what build systems are available - cmake, make etc --> In this case, we simply untar the package, configure it to point to the `$SOFT_DIR` prefix and install.

## Create the artifact

```bash
mkdir -p $REPO_DIR
rm -rf $REPO_DIR/*
tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo
```
If the build passes, we create the artifact - simply a tarball which contains the right paths, ready to be staged into the testing repo. The artifact is `$REPO_DIR/build.tar.gz` and should be redistributable to sites which it has been compiled for.

## Create the modulefile

```bash
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       GMP_VERSION       $VERSION
setenv       GMP_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(GMP_DIR)/lib
MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME
```
This step is quite self-explanatory - it creates the modulefile necessary for using the application or library. Again, it's up to the developer to know what paths to append and what dependencies to encode in the modulefile.

In this case, we are building a library, so it goes in the `$LIBRARIES_MODULES` subdirectory, using the version of the package as the name.

# Exit and Failure codes

Note that we haven't failed fast or frequently here, but we should... <!-- todo --> 
