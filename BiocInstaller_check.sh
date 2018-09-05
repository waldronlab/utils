#!/bin/bash

BIOC="/data/16tb/Bioconductor/"

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
    ## Among all Bioconductor packages, what PACKAGES mention 'BiocInstaller'
    ## or 'biocLite'?
    find . -name '.git' -type d -prune \
        -o -name 'data' -type d -prune \
        -o -name 'doc' -type d -prune \
        -o -regextype posix-egrep -regex ".*(\.[Rr]?[DdNnMmWw]*|NAMESPACE|DESCRIPTION)$" -type f -print0 | \
        xargs -0 grep -EI --color \
        --exclude={*\.[Rr][Dd][AaSs],*\.[Rr][Dd]ata,*\.Rhistory,*\.txt,*NEWS*,*\.html,Makefile,\.travis\.yml} \
        'BiocInstaller|biocLite|biocValid|biocVersion|biocinstallRepos'
| \
    cut -d/ -f2 | sort | \
    uniq > $BIOC/$folder/${i}_BiocInstaller_biocLite_PKGS.txt

if [ "$i" = 'software' ]
then
    ## Among all Bioc dev-team packages, what PACKAGES contain 'BiocInstaller'?
    cat /home/$USER/Bioconductor/GitContribution/inst/extdata/packages_maintained_by_bioc.txt | \
    xargs grep -Er --exclude-dir={.git,data} 'BiocInstaller|biocLite' | \
    cut -d/ -f1 | sort | uniq > $BIOC/$folder/${i}_BiocMaintained_PKGS.txt
fi
    cd $BIOC
done

# for i in ${pkg_type[@]}
# do
#     cd $BIOC/git.bioconductor.org/$i
#     ## Among all Bioconductor packages, what LINES mention 'BiocInstaller'?
#     find . -type f -print0 | xargs -0 grep -Ern --exclude-dir={.git,data} 'BiocInstaller|biocLite' \
#     > $BIOC/$folder/${i}_BiocInstaller_biocLite_lines.txt
# 
#     ## Among all Bioc dev-team packages, what LINES contain 'BiocInstaller'?
#     cat /home/$USER/Bioconductor/GitContribution/inst/extdata/packages_maintained_by_bioc.txt | \
#     xargs grep -Ern --exclude-dir={.git,data} 'BiocInstaller|biocLite' > $BIOC/$folder/${i}_BiocMaintained_lines.txt
# done

