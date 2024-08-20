#!/bin/bash

export _R_CHECK_FORCE_SUGGESTS_=FALSE

BIOC_LIBS=$HOME/R/bioc-devel
# BIOC_LIBS=/media/$USER/$DRIVEID/bioc-devel/

alias biocdev="R_LIBS_USER=$BIOC_LIBS $HOME/src/svn/r-4-4/R/bin/R --no-save --no-restore-data --no-environ"

cd ~/bioc/

alias scrub='find . -maxdepth 1 -type f -name "*.tar.gz" -exec rm {} \; && find . -maxdepth 1 -type d -name "*.Rcheck" -exec rm -rf {} \; && find . -maxdepth 1 -type d -name "*.BiocCheck" -exec rm -rf {} \;'
scrub

anvilpackages=("AnVILBase" "AnVIL" "AnVILGCP" "AnVILAz")

for key in "${!anvilpackages[@]}"
do
    cd ${anvilpackages[$key]}
    biocdev CMD build --no-build-vignettes .
    biocdev CMD check --no-build-vignettes ${anvilpackages[$key]}_*.tar.gz
    ${scrub}
    cd ..
done
