#!/bin/bash

LITE_CALL="biocLite"
BIOC_INST="BiocInstaller"
SOURCE_FILES=".*\.[Rr]?[DdNnMmWw]*$"
DESC_FILE="DESCRIPTION"
BIOC_MGR="\1if (!requireNamespace(\"BiocManager\", quietly=TRUE))\2\\
    \1install.packages(\"BiocManager\")\2"
CODE_BIOCLITE="\1install.packages(\"BiocManager\")\2"
MGR_INST="BiocManager::install"

SOURCE_LINE_REGEXP="^([#\ \`]*)source\([\"']http.*$LITE_CALL\.R[\"']\)(.*)$"
CODE_BIOCLITE_REGEXP="^(.*)source\([\"']http.*$LITE_CALL\.R[\"']\)(.*)$"

# SOURCE_LINE_REGEXP="^(\s*)(\`)*source\(.*http.*$LITE_CALL\.R.*\)\`*\s*$"
LIBRARY_LINE_REGEXP="^\s*library\(.*$BIOC_INST.*\)\s*$"
FULL_CALL_REGEXP="$BIOC_INST[:|\ ]*$LITE_CALL"
BIOCLITE_CALL_REGEXP="(.*)$LITE_CALL(\(.*)$"

library_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$LIBRARY_LINE_REGEXP" {} \+`

if [ ! -z "${library_hits// }" ]; then
    echo "Replacing any library\(BiocInstaller\) with BiocManager..."

    for i in $library_hits;
    do
        sed -i "s/\<$BIOC_INST\>/BiocManager/" $i
    done
fi

## for DESCRIPTION files
sed -i "s/\<$BIOC_INST\>/BiocManager/" $DESC_FILE

source_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$SOURCE_LINE_REGEXP" {} \+`

if [ ! -z "${source_hits// }" ]; then
    echo "Replacing source('.../biocLite.R') with install.packages('BiocManager')"

    for i in $source_hits;
    do
        sed -E -i "s|$SOURCE_LINE_REGEXP|$BIOC_MGR|" $i
    done
fi

code_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$CODE_BIOCLITE_REGEXP" {} \+`

if [ ! -z "${code_hits// }" ]; then
    echo "Replacing source(.../biocLite.R) with install.packages"

    for i in $code_hits;
    do
        sed -E -i "s|$CODE_BIOCLITE_REGEXP|$CODE_BIOCLITE|" $i
    done
fi

biocLite_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$BIOCLITE_CALL_REGEXP" {} \+`

if [ ! -z "${biocLite_hits// }" ]; then
    echo "Replacing biocLite() with BiocManager::install()"

    for i in $biocLite_hits;
    do
        sed -i "s/\<$FULL_CALL_REGEXP\>/$MGR_INST/" $i
        sed -E -i "s|$BIOCLITE_CALL_REGEXP|\1$MGR_INST\2|g" $i
    done
fi

LITE_FILES="$library_hits $source_hits $biocLite_hits"

