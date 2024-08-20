#!/bin/bash

export _R_CHECK_FORCE_SUGGESTS_=FALSE

alias devr="R_LIBS_USER=$HOME/R/r-devel $HOME/src/svn/r-devel/R/bin/R --vanilla"
alias relr="R_LIBS_USER=$HOME/R/r-4-4 $HOME/src/svn/r-4-4/R/bin/R --vanilla"
alias oldr="R_LIBS_USER=$HOME/R/r-4-3 $HOME/src/svn/r-4-3/R/bin/R --vanilla"

cd ~/bioc/

rm *.tar.gz

oldr CMD build --no-build-vignettes BiocManager &&
    oldr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

relr CMD build --no-build-vignettes BiocManager &&
    relr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

devr CMD build --no-build-vignettes BiocManager &&
    devr CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

