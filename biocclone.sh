#!/bin/bash
# clone repository from git.bioconductor.org
#
# 1 - package name

PKG=$1

## if package does not exist clone it

if [ ! -d "$PKG" ]; then
    git clone git@git.bioconductor.org:packages/$PKG.git 
fi

_R_CHECK_INSTALL_DEPENDS_=true R_LIBS_USER=/home/mramos/R/bioc-devel /home/mramos/src/svn/r-4-6/inst/bin/R --no-save --no-restore-data \
    -e "remotes::install_local('$PKG', dependencies=TRUE, repos = BiocManager::repositories())"

