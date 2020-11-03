#!/bin/bash
# clone GitHub and Bioc.git repositories

# 1 - package name

PKG=$1

git clone git@github.com:Bioconductor/$PKG.git && cd $PKG

git remote add upstream git@git.bioconductor.org:packages/$PKG.git && cd ..

