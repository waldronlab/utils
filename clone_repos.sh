#!/bin/bash

# eval "$(ssh-agent -s)"
# ssh-add

. ./utils/setBIOC.sh

pkg_type=$1

if [ -z ${pkg_type// } ]; then
    pkg_type=( 'software' 'data-experiment' 'workflows' )
fi

cd $BIOC

for item in "${pkg_type[@]}"; do

    if [ "$item" == "software" ]; then
        # clone software package repos (takes approx. 1h10)
        time $BBS_HOME/utils/update_bioc_git_repos.py software devel
    fi

    if [ "$item" == "data-experiment" ]; then
        # clone data-experiment package repos (takes approx. 1h45)
        time $BBS_HOME/utils/update_bioc_git_repos.py data-experiment devel
    fi

    if [ "$item" == "workflows" ]; then
        # clone workflow package repos (takes approx. 4 min)
        time $BBS_HOME/utils/update_bioc_git_repos.py workflows devel
    fi

done


