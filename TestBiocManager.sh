#!/bin/bash

export _R_CHECK_FORCE_SUGGESTS_=FALSE

devr() { R_LIBS_USER=$HOME/R/r-devel $HOME/src/svn/r-devel/inst/bin/R --vanilla "$@"; }
relr() { R_LIBS_USER=$HOME/R/r-4-6 $HOME/src/svn/r-4-6/inst/bin/R --vanilla "$@"; }
oldr() { R_LIBS_USER=$HOME/R/r-4-5 $HOME/src/svn/r-4-5/inst/bin/R --vanilla "$@"; }

cd ~/bioc/

rm -f *.tar.gz

oldr CMD build --no-build-vignettes BiocManager &&
    oldr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

relr CMD build --no-build-vignettes BiocManager &&
    relr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

devr CMD build --no-build-vignettes BiocManager &&
    devr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

