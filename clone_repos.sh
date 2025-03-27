#!/bin/bash

branch=$1

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

BIOC="$HOME/bioc"
REPO_BASE=git@git.bioconductor.org

cd $BIOC

git clone git@git.bioconductor.org:admin/manifest
git checkout $branch origin/$branch

cd manifest

PACKAGES=(
    $(grep "^Package:" software.txt | cut -d: -f2 | tr -d ' ')
)

cd ..

for pkg in "${PACKAGES[@]}"
do
    echo "Attempting to clone $pkg..."
    if [ ! -d "$BIOC/$pkg" ]; then
        git clone $REPO_BASE:packages/$pkg.git
    else
        cd $BIOC/$pkg && git pull origin $branch
    fi
done

