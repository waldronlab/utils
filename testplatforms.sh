#!/bin/bash

version=$1
PKG='BiocManager'
MGR="$HOME/Bioconductor/$PKG"

if [ -z "${version// }" ]; then
    version=( "release" "devel" "oldrel" )
else
    version=( $1 )
fi

for rver in "${version[@]}"
do
    LIBLOC="$HOME/R/r-${rver}"
    echo "Setting LIBLOC = $LIBLOC"
    if [ ! -d $LIBLOC ]; then
        mkdir -p $LIBLOC
    fi

    R_LIBS_USER="$HOME/R/r-${rver}"
    echo "Setting R_LIBS_USER = \"$HOME/R/r-${rver}\""

    rversion="$HOME/src/svn/r-${rver}/R/bin/R --vanilla"
    
    ${rversion} -e "deps <- c('knitr', 'testthat', 'remotes', 'stringr'); if (!all(deps %in% rownames(installed.packages()))) install.packages(deps)"

    cd $LIBLOC

    echo "** ${rversion} CMD build $MGR"
    ${rversion} CMD build $MGR

    TARBALL=$(echo ${PKG}_*)

    echo "** _R_CHECK_FORCE_SUGGESTS_=FALSE ${rversion} CMD check ${TARBALL}"
    _R_CHECK_FORCE_SUGGESTS_=FALSE ${rversion} CMD check ${TARBALL}

    if [ $? -ne 0 ]; then
        echo "Unable to check package without errors"
        exit 2
    fi

    echo "** Removing tarball... rm ${TARBALL}"
    rm ${TARBALL}

done
