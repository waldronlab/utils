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

    R_LIBS_USER="$HOME/R/r-${rver}"
    echo "Setting R_LIBS_USER = \"$HOME/R/r-${rver}\""

    rversion="$HOME/src/svn/r-${rver}/R/bin/R --vanilla"
    
#    ${rversion} -e "install.packages(c('knitr', 'testthat', 'remotes', 'stringr'))"

    cd $LIBLOC

    echo "** ${rversion} CMD build $MGR"
    ${rversion} CMD build $MGR

    TARBALL=$(echo ${PKG}_*)

    echo "** _R_CHECK_FORCE_SUGGESTS_=FALSE ${rversion} CMD check ${TARBALL}"
    _R_CHECK_FORCE_SUGGESTS_=FALSE ${rversion} CMD check ${TARBALL}

    echo "** Removing tarball... rm ${TARBALL}"
    rm ${TARBALL}
done
