#!/bin/bash

. $BIOC/utils/replace_biocLite.sh

INST_REPOS="biocinstallRepos"
BIOC_VALID="biocValid"
BIOC_VERS="biocVersion"
BIOC_INST="BiocInstaller"

NS="NAMESPACE"
SOURCE_FILES=".*\(\.R\|$NS\|\.[Rr][NnMm][WwDd]\|\.[Rr][Dd]\)"

instrepos_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -wl "$INST_REPOS" {} \+`

if [ ! -z "${instrepos_hits// }" ]; then
    echo "Replacing any biocinstallRepos with BiocManager::repositories..."

    for i in $instrepos_hits;
    do
        sed -i "s/\<$INST_REPOS\>/repositories/" $i
        sed -i "s/\<$BIOC_INST\>/BiocManager/g" $i
    done
fi

biocvalid_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -wl "$BIOC_VALID" {} \+`


if [ ! -z "${biocvalid_hits// }" ]; then
    echo "Replacing any biocValid with BiocManager::valid..."

    for i in $biocvalid_hits;
    do
        sed -i "s/\<$BIOC_VALID\>/valid/" $i
    done
fi

biocvers_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -wl "$BIOC_VERS" {} \+`

if [ ! -z "${biocvers_hits// }" ]; then
    echo "Replacing any biocVersion with BiocManager::version"
    for i in $biocvers_hits;
    do
        sed -i "s/\<$BIOC_VERS\>/version/" $i
    done
fi

ALT_FILES="$instrepos_hits $biocvalid_hits $biocvers_hits"

TOT_FILES="$LITE_FILES $ALT_FILES"

if [ -z "${TOT_FILES// }" ]; then
    exit 0
else
    TOTAL=`echo $TOT_FILES | tr " " "\n" | uniq | wc -l`
    echo "Done. $TOTAL file(s) modified."
    exit 1
fi

