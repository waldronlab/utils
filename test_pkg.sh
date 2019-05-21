#!/bin/bash

pkg=$1
cwd=$(pwd)
pkg_dir=$cwd/$pkg

for name in oldrel release devel
do
    R_LOC=$HOME/src/svn/r-${name}/R/bin/R
    LIB_DIR=$HOME/src/lib/r-${name}/
    TAR_LOC=$HOME/src/tar/r-${name}/

    if [ ! -d $LIB_DIR ]; then
        mkdir -p $LIB_DIR
    fi

    if [ ! -d $TAR_LOC ]; then
        mkdir -p $TAR_LOC
    fi

    echo "-*-*- Testing $pkg on r-${name}..."
    cd $TAR_LOC
    export R_LIBS_USER=$LIB_DIR
    $R_LOC --vanilla CMD build --no-build-vignettes $pkg_dir
    echo "-*-*- Installing $pkg dependencies for r-${name}"
    $R_LOC --vanilla -e "dcf <- read.dcf('${pkg_dir}/DESCRIPTION', 'Suggests'); pkgs <- trimws(strsplit(dcf, \"[,\n ]+\")[[1L]]); need <- pkgs[!pkgs %in% rownames(installed.packages())]; install.packages('BiocManager', repos = 'https://cloud.r-project.org/'); BiocManager::install(need, ask = FALSE)"
    echo "-*-*- Checking $pkg on r-${name}"
    $R_LOC --vanilla CMD check $TAR_LOC/${pkg}_*.tar.gz
    export R_LIBS_USER=""
    if [ $? -ne 0 ]; then
        echo "Unable to check package without errors"
        exit 2
    fi
done

