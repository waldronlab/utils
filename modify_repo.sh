#!/bin/bash
# 1 - options: software, data-experiment, workflows
# 2 - options: gsub, reset, diff, push, status

## gsub - Run replacement script and bump package 'z' version
## reset - revert the package changes to most recent commit
## diff - see changes with git diff
## push - push changes to git.bioc

pkg_type=$1
CMD=$2

BIOC='/data/16tb/Bioconductor'
GIST_FOLDER='44cc844a169d5d96c777a69037dae653'
LIST_FILE="${pkg_type}_BiocInstaller_biocLite_PKGS.txt"
EXCLUDE=(BiocInstaller)

cd $BIOC

# GIST_FOLDER clone
# git clone git@gist.github.com:$GIST_FOLDER.git

readarray -t PKGS < $BIOC/$GIST_FOLDER/$LIST_FILE

PKGS=("${PKGS[@]/$EXCLUDE}")

for i in ${PKGS[@]}
do
    cd $BIOC/git.bioconductor.org/$pkg_type/$i
    echo "Working on package: $i..."

    if [ "$CMD" == "gsub" ]; then
        $BIOC/utils/gsub_biocLite.sh
        retVal=$?
        if [ $retVal -ne 0 ]; then
            $BIOC/utils/version_bump.sh
        fi
    elif [ "$CMD" == "reset" ]; then
        git checkout -- .
    elif [ "$CMD" == "push" ]; then
        git remote set-url origin git@git.bioconductor.org:packages/$i.git
        git remote -v
        git commit -am "replace BiocInstaller biocLite mentions with BiocManager"
        git push origin master
    elif [ "$CMD" == "diff" ]; then
        git diff
    elif [ "$CMD" == "status" ]; then
        git status
    else
        echo "$CMD is not a valid option"
    fi
done

cd $BIOC
