# Things to consider when committing new files.

Good practice requires that each file committed to the repository has a function, which should be made clear in a header to the newcomer. This file provides a template.

## Raison d'Etre

This is the header which should be included in all files contributed to this repository by members of the Africa-Arabia Regional Operations Team. It is to attribute the work to the author, as well as to keep track of which issues (if applicable) the file closes or responds to.

## Copyright.
The ROC is a collaboration of institutes, each of which have their internal policies on ownership of code written by their employees. This means that we can't include a single copyright statement in the repository, but have to add a line similar to

----------

Copyright &copy; FunWorks Inc 0 - &infin; ; for full copyright statement, please see this.link.com

For example, for work contributed by CSIR employees -

"Copyright &copy; 2010 - 2015 CSIR, for full copyright notice, see http://www.csir.co.za/meraka/copyright.html"

-----------

## Issues
Github isues are commonly opened to request applications, and to track their dependencies. If the file you are contributing responds to an issue or resolves an issue, you can link it in the header. This is highly recommended, especially in the case of contributing new applications to the repository.

# YAML frontmatter

If you're writing something that understands Markdown, use the following front matter:
```
---
Category: e.g. Documentation
Description: short description
Tags:
  - Documentation
  - etc
  - etc
License: Apache
Copyright:
  - Author: First Author
  - Institute: Institute(s) that hold(s) copyright.
---
```
# Header
Include the text beneath "cut below" below in your files :

<------ cut below -------->
```
###############################################
# Africa-Arabia Regional Operations Centre
# This source code is under the copyright of institute X (link)
# Title                   : <put the name of the file here>
# First Author            :
# Institute               :
# Ticket (optional)       : <URL of Trac ticket>
# Copyright (optional)    : <url of copyright notice, if relevant>
###############################################
#
# Short Description
#
# Put a short description of what this file does here
#
#

here is some more text :)
here is even more text.
```
