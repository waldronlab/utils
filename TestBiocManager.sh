#!/bin/bash

export _R_CHECK_FORCE_SUGGESTS_=FALSE

cd ~/bioc/

rm *.tar.gz

Rold --vanilla CMD build --no-build-vignettes BiocManager &&
    Rold --vanilla CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

Rrel --vanilla CMD build --no-build-vignettes BiocManager &&
    Rrel --vanilla CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz

Rdev --vanilla CMD build --no-build-vignettes BiocManager &&
    Rdev --vanilla CMD check --as-cran --no-build-vignettes BiocManager_*tar.gz
