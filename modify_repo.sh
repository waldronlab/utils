#!/bin/bash
# 1 - options: gsub, reset, push

## gsub - Run replacement script and bump package 'z' version
## reset - revert the package changes to most recent commit
## push - push changes to git.bioc
## diff - see changes with git diff


CMD=$1

BIOC='/data/16tb/Bioconductor'
GIST_FOLDER='44cc844a169d5d96c777a69037dae653'
LIST_FILE='software_BiocInstaller_biocLite_PKGS.txt'

cd $BIOC

readarray -t PKGS < $BIOC/$GIST_FOLDER/$LIST_FILE

# testing
# for i in ${PKGS[@]:0:5}

for i in ${PKGS[@]}
do
    cd $BIOC/git.bioconductor.org/software/$i

    if [ "$CMD" == "gsub" ]; then
        $BIOC/utils/gsub_biocLite.sh $i
        bash $BIOC/utils/version_bump.sh
    elif [ "$CMD" == "reset" ]; then
        git checkout -- .
    elif [ "$CMD" == "push" ]; then
        git remote set-url origin git@git.bioconductor.org:packages/$i.git
        git commit -am "replace BiocInstaller biocLite mentions with BiocManager"
        git push
    elif [ "$CMD" == "diff" ]; then
        git diff
    else
        echo "$CMD is not a valid option"
    fi
done

cd $BIOC