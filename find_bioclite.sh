#!/bin/bash

BIOC="/home/$USER/Bioconductor"
pkgname=$1

cd $BIOC

git clone git@github.com:Bioconductor/$pkgname.git

cd $pkgname

git remote add upstream git@git.bioconductor.org:packages/$pkgname.git
git pull upstream master

vim -O $(grep -Elr --exclude-dir="\.git" 'BiocInstaller|biocLite' | cut -d: -f2 | uniq) 

