#!/bin/bash
# 1 - git address - git@github.com:Bioconductor/Organism.dplyr.git

pkg_ssh=$1
PKG=`echo $pkg_ssh | cut -d/ -f2 | rev | cut -d. -f2- | rev`

git clone git@github.com:Bioconductor/$PKG.git && cd $PKG

git remote add upstream git@git.bioconductor.org:packages/$PKG.git && cd ..

