#!/bin/bash

. ./utils/setBIOC.sh

pkg_type=$1

if [ -z ${pkg_type// } ]; then
    pkg_type=( 'software' 'data-experiment' 'workflows' )
fi

folder='44cc844a169d5d96c777a69037dae653'

for i in ${pkg_type[@]}
do
    locate=$BIOC/git.bioconductor.org/$i
    cd $locate
    echo $locate
    $BIOC/utils/find_keywords.sh | \
    cut -d/ -f2 | sort | \
    uniq > $BIOC/$folder/${i}_BiocInstaller_biocLite_PKGS.txt

if [ "$i" = 'software' ]
then
    ## Among all Bioc dev-team packages, what PACKAGES contain 'BiocInstaller'?
    cat /home/$USER/Bioconductor/GitContribution/inst/extdata/packages_maintained_by_bioc.txt | \
    xargs grep -Er --exclude-dir={.git,data} 'BiocInstaller|biocLite' | \
    cut -d/ -f1 | sort | uniq > $BIOC/$folder/${i}_BiocMaintained_PKGS.txt
fi

done

