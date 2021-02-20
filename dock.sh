#!/bin/bash

## optionally set a DOCK_REPO_PREFIX e.g., $HOME/docker-
## to set the main package installation directory

version=$1

if [ -z "${DOCK_REPO_PREFIX// }" ]; then
    DOCK_REPO_PREFIX=$HOME
fi

DOCK_FOLDER=$DOCK_REPO_PREFIX${version}

if [ $version == "release" ]; then
    dock_ver="RELEASE_3_12"
else
    dock_ver=$version
fi

docker run -v $DOCK_FOLDER:/usr/local/lib/R/host-site-library -v $HOME/dockerhome:/home/rstudio -e PASSWORD=bioc -p 8787:8787 bioconductor/bioconductor_docker:$dock_ver
