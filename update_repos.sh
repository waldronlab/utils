#!/bin/bash

BIOC='/data/16tb/Bioconductor'
GIST_FOLDER='44cc844a169d5d96c777a69037dae653'
LIST_FILE='software_BiocInstaller_biocLite_PKGS.txt'

cd $BIOC

readarray -t PKGS < $BIOC/$GIST_FOLDER/$LIST_FILE

for i in ${PKGS[@]}
do
    cd $BIOC/git.bioconductor.org/software/$i
    git remote set-url origin git@git.bioconductor.org:packages/$i.git
    git push 
done

cd $BIOC

