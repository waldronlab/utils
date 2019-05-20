#!/bin/bash

pkg=$1

for name in devel release oldrel
do
    R_LOC=$HOME/src/svn/r-${name}/R/bin/R
    LIB_DIR=$HOME/src/lib/r-${name}
    if [ ! -d $lib_dir ]; then
        mkdir -p $lib_dir
    fi
    echo "Testing $pkg on r-${name}..."
    R_LIBS_USER=$LIB_DIR $R_LOC --vanilla CMD build $pkg
    echo "Checking $pkg on r-${name}"
    R_LIBS_USER=$LIB_DIR $R_LOC --vanilla CMD check ${pkg}_*.tar.gz
done



