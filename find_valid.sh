#!/bin/bash
# 1 - package name (if none, taken from list in gist)
# 2 - options: search, line

## search - look at previous commit histories for packages
## line - find what line includes "valid"
## package - get what package includes "valid"

PKGS=$1
CMD=$2

BIOC="/data/16tb/Bioconductor/"
GIST_FOLDER='44cc844a169d5d96c777a69037dae653'
LIST_FILE="software_valid_PKGS.txt"
EXCLUDE=( BiocInstaller AnnotationHub AnnotationHubData BiocCheck )

LOC=$BIOC/git.bioconductor.org/software
cd $LOC
echo $LOC

## Among all Bioconductor packages, what PACKAGES mention 'valid'
## or 'biocLite'?
find . -name '.git' -type d -prune \
    -o -name 'data' -type d -prune \
    -o -name 'doc' -type d -prune \
    -o -name 'scripts' -type d -prune \
    -o -regextype posix-egrep -regex ".*(\.[Rr]?[DdNnMmWw]*|NAMESPACE|DESCRIPTION)$" -type f -print0 | \
    xargs -0 grep -EI --color \
    --exclude={*\.[Rr][Dd][AaSs],*\.[Rr][Dd]ata,*\.Rhistory,*\.txt,*NEWS*,*\.html,Makefile,\.travis\.yml} \
    'valid' | \
cut -d/ -f2 | sort | uniq > $BIOC/$GIST_FOLDER/$LIST_FILE

if [ -z "${PKGS// }" ]; then
    readarray -t PKGS < $BIOC/$GIST_FOLDER/$LIST_FILE
fi

for dex in ${EXCLUDE[@]}
do
    PKGS=("${PKGS[@]/$dex}")
done

for i in ${PKGS[@]}
do
    cd $BIOC/git.bioconductor.org/$pkg_type/$i
    echo "Working on package: $i..."

    if [ "$CMD" == "search" ]; then
        git show HEAD~3
    elif [ "$CMD" == "line" ]; then
        git show HEAD~3 | grep -E "valid|biocVersion"
    elif [ "$CMD" == "package" ]; then
        nlines=`git show HEAD~3 | grep -E "valid|biocVersion" | wc -l` 
        if [ "$nlines" -gt 0 ]; then
            echo ${i}
        fi
    fi
done
