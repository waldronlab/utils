#!/bin/bash
$1
package='Foo'
cd $package

SOURCE_FILES=".*\.[Rr]?[DdNnMmWw]*$"

files=`find . ! -path . -regex "$SOURCE_FILES"`

hit_files=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$LIBRARY_LINE_REGEXP" {} \+`

for i in $hit_files;
do
    sed -i "s/\<$BIOC_PKG\>/BiocManager/" $i
done

cd ~/
BIOC_PKG="BiocInstaller"
LITE_CALL="biocLite"

LIBRARY_LINE_REGEXP="^\s*library\(.?$BIOC_PKG.?\)\s*$"

SOURCE_LINE_REGEXP="^\s*source\(.?http.*/$LITE_CALL\.R.?\)\s*$"

BIOCLITE_CALL_REGEXP="^\s*$LITE_CALL\(.*$package.*\)\s*$"

## for every file in files
old_library_line=`grep -E $LIBRARY_LINE_REGEXP ~/test/test_calls.txt`
old_source_line=`grep -E $SOURCE_LINE_REGEXP ~/test/test_calls.txt`
old_bioclite_line=`grep -E $BIOCLITE_CALL_REGEXP ~/test/test_calls.txt`

#test
old_library_line='library("BiocInstaller")'

echo $old_library_line | sed "s/\<$BIOC_PKG\>/BiocManager/"

#test
old_source_line='source("https://bioconductor.org/biocLite.R")'

biocmanager="if (!requireNamespace(\"BiocManager\"))\\
    install.packages(\"BiocManager\")"

echo $old_source_line | sed "s|${old_source_line}|${biocmanager}|"

#test
old_bioclite_line='biocLite("Foo")'

echo $old_bioclite_line | sed "s/\<$LITE_CALL\>/install/"
