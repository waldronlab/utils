#!/bin/bash

version=$1
PKG='BiocManager'
MGR="$HOME/bioc/$PKG"

if [ -z "${version// }" ]; then
    version=( "4-5" "4-6" "devel" )
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

    R_LIBS_USER="$HOME/R/r-${rver}" \
    "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla -e "deps <- c('knitr', 'testthat', 'remotes', 'stringr', 'rmarkdown', 'bookdown', 'BiocManager'); options(Ncpus = 24); if (!all(deps %in% rownames(installed.packages()))) install.packages(deps, repos = 'https://cloud.r-project.org/'); setRepositories(ind = 2); install.packages('BiocStyle')"

    R_LIBS_USER="$HOME/R/r-${rver}" \
    "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla -e "if (packageVersion('testthat') < '3.3.0') remotes::install_github('r-lib/testthat')"

    cd $R_LIBS_USER
    rm -rf ${PKG}_*

    echo "** $HOME/src/svn/r-${rver}/inst/bin/R --vanilla CMD INSTALL $MGR"

    R_LIBS_USER="$HOME/R/r-${rver}" "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla CMD INSTALL $MGR

    R_LIBS_USER="$HOME/R/r-${rver}" \
    "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla -e "if (!require('BiocStyle', quietly = TRUE)) BiocManager::install('BiocStyle')"

    echo "** $HOME/src/svn/r-${rver}/inst/bin/R --vanilla CMD build $MGR"

    R_LIBS_USER="$HOME/R/r-${rver}" "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla CMD build $MGR

    TARBALL=$(echo ${PKG}_*)

    echo "** _R_CHECK_FORCE_SUGGESTS_=FALSE _R_CHECK_DEPENDS_ONLY=TRUE $HOME/src/svn/r-${rver}/inst/bin/R --vanilla CMD check ${TARBALL}"
    R_LIBS_USER="$HOME/R/r-${rver}" \
    _R_CHECK_FORCE_SUGGESTS_=FALSE _R_CHECK_DEPENDS_ONLY=TRUE "$HOME/src/svn/r-${rver}/inst/bin/R" --vanilla CMD check --as-cran ${TARBALL}

    if [ $? -ne 0 ]; then
        echo "Unable to check package without errors"
        echo "** Removing tarball... rm ${TARBALL}"
        rm ${TARBALL}
        exit 2
    fi
done

