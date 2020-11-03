#!/bin/bash

## Among all Bioconductor packages, what PACKAGES mention 'BiocInstaller'
## or 'biocLite'?
find . -name '.git' -type d -prune \
-o -name 'data' -type d -prune \
-o -name 'doc' -type d -prune \
-o -name 'scripts' -type d -prune \
-o -regextype posix-egrep -regex ".*(\.[Rr]?[DdNnMmWw]*|NAMESPACE|DESCRIPTION)$" -type f -print0 | \
xargs -0 grep -EI --color \
--exclude={*\.[Rr][Dd][AaSs],*\.[Rr][Dd]ata,*\.Rhistory,*\.txt,*NEWS*,*\.html,Makefile,\.travis\.yml} \
'BiocInstaller|biocLite|biocValid|biocVersion|biocinstallRepos'

