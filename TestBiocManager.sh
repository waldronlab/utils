#!/bin/bash

export _R_CHECK_FORCE_SUGGESTS_=FALSE

Rold --vanilla CMD build --no-build-vignettes BiocManager &&
    Rold --vanilla CMD check --as-cran --no-build-vignettes BiocManager_1.30.10.12.tar.gz

Rrel --vanilla CMD build --no-build-vignettes BiocManager &&
    Rrel --vanilla CMD check --as-cran --no-build-vignettes BiocManager_1.30.10.12.tar.gz

Rdev --vanilla CMD build --no-build-vignettes BiocManager &&
    Rdev --vanilla CMD check --as-cran --no-build-vignettes BiocManager_1.30.10.12.tar.gz
