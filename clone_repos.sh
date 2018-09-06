#!/bin/bash

# eval "$(ssh-agent -s)"
# ssh-add

pkg_type=$1

if [ -z ${pkg_type// } ]; then
    pkg_type=( 'software' 'data-experiment' 'workflows' )
fi

export BBS_HOME="/data/16tb/Bioconductor/BBS"
export PYTHONPATH="$BBS_HOME/bbs"
export BIOC="/data/16tb/Bioconductor/"

cd $BIOC

# clone software package repos (takes approx. 1h10)
time $BBS_HOME/utils/update_bioc_git_repos.py software master

# clone data-experiment package repos (takes approx. 1h45)
time $BBS_HOME/utils/update_bioc_git_repos.py data-experiment master

# clone workflow package repos (takes approx. 4 min)
time $BBS_HOME/utils/update_bioc_git_repos.py workflows master

