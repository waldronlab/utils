#!/bin/bash

version=$1
PKG='BiocManager'
MGR="$HOME/bioc/$PKG"

if [ -z "${version// }" ]; then
    version=( "4-2" "4-3" "devel" )
else
    version=( $1 )
fi

for rver in "${version[@]}"
do
    echo "Setting R_LIBS_USER = \"$HOME/R/r-${rver}\""
    R_LIBS_USER="$HOME/R/r-${rver}"
    if [ ! -d $R_LIBS_USER ]; then
        mkdir -p $R_LIBS_USER
    fi

    rversion="$HOME/src/svn/r-${rver}/R/bin/R --vanilla"
    
    R_LIBS_USER="$HOME/R/r-${rver}" \
    ${rversion} -e "deps <- c('knitr', 'testthat', 'remotes', 'stringr', 'rmarkdown'); options(Ncpus = 24); if (!all(deps %in% rownames(installed.packages()))) install.packages(deps, repos = 'https://cloud.r-project.org/')"

    cd $R_LIBS_USER
    rm -rf ${PKG}_*

    echo "** ${rversion} CMD build $MGR"

    R_LIBS_USER="$HOME/R/r-${rver}" ${rversion} CMD build $MGR

    TARBALL=$(echo ${PKG}_*)

    echo "** _R_CHECK_FORCE_SUGGESTS_=FALSE _R_CHECK_DEPENDS_ONLY=TRUE ${rversion} CMD check ${TARBALL}"
    R_LIBS_USER="$HOME/R/r-${rver}" \
    _R_CHECK_FORCE_SUGGESTS_=FALSE _R_CHECK_DEPENDS_ONLY=TRUE ${rversion} CMD check --as-cran ${TARBALL}

    if [ $? -ne 0 ]; then
        echo "Unable to check package without errors"
        echo "** Removing tarball... rm ${TARBALL}"
        rm ${TARBALL}
        exit 2
    fi
done

