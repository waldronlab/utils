#!/bin/bash

PKGNAME=$1

git clone git@git.bioconductor.org:packages/$PKGNAME.git && cd $PKGNAME

./utils/find_keywords.sh

