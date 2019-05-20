#!/bin/bash

pkg=$1
cwd=$(pwd)
pkg_dir=$cwd/$pkg

for name in devel release oldrel
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

    echo "Testing $pkg on r-${name}..."
    cd $TAR_LOC
    export R_LIBS_USER=$LIB_DIR
    $R_LOC --vanilla CMD build --no-build-vignettes $pkg_dir
    echo "Checking $pkg on r-${name}"
    $R_LOC --vanilla CMD check $TAR_LOC/${pkg}_*.tar.gz
    retVal=$?
        if [ $retVal -ne 0 ]; then
            INSTOUT=$TAR_LOC/${pkg}.Rcheck/00check.log
            $R_LOC --vanilla -e "
            rlines <- readLines('${INSTOUT}')
            lpkgs <- grep('Packages suggested but not available:', rlines)+1L
            inpkgs <- gsub(\" |'\", '', unlist(strsplit(rlines[lpkgs], \"', '\")))
            install.packages('BiocManager', repos = 'https://cloud.r-project.org/')
            BiocManager::install(inpkgs, ask = FALSE)
            "
            $R_LOC --vanilla CMD check $TAR_LOC/${pkg}_*.tar.gz
            if [ $? -ne 0 ]; then
                echo "Unable to install necessary dependencies"
                exit 2
            fi
        fi
    export R_LIBS_USER=""
done



