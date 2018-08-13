#!/bin/bash

BIOC="/path/to/Bioconductor/"

pkg_type=( 'software' 'data-experiment' 'workflows' )
folder='grepOut'

for i in ${pkg_type[@]}
do
    cd $BIOC/git.bioconductor.org/$i

    ## Among all Bioconductor packages, what PACKAGES mention 'BiocInstaller' or 'biocLite'?
    find . -type f -print0 | xargs -0 grep -E --exclude-dir={.git,data} \
    --exclude={\.[Rr][Dd][AaSs],.R[Dd]ata} 'BiocInstaller|biocLite' | \
    cut -d/ -f2 | sort | uniq > $BIOC/$folder/${i}_BiocInstaller_biocLite_PKGS.txt

if [ "$i" = 'software']
then
    ## Among all Bioc dev-team packages, what PACKAGES contain 'BiocInstaller'?
    cat /home/$USER/Bioconductor/GitContribution/inst/extdata/packages_maintained_by_bioc.txt | \
    xargs grep -Er --exclude-dir={.git,data} 'BiocInstaller|biocLite' | cut -d/ -f1 | sort | uniq \
    > $BIOC/$folder/${i}_BiocMaintained_PKGS.txt
fi
done

# for i in ${pkg_type[@]}
# do
#     cd $BIOC/git.bioconductor.org/$i
#     ## Among all Bioconductor packages, what LINES mention 'BiocInstaller'?
#     find . -type f -print0 | xargs -0 grep -Ern --exclude-dir={.git,data} 'BiocInstaller|biocLite' \
#     > $BIOC/$folder/${i}_BiocInstaller_biocLite_lines.txt
# 
#     ## Among all Bioc dev-team packages, what LINES contain 'BiocInstaller'?
#     cat /home/$USER/Bioconductor/GitContribution/inst/extdata/packages_maintained_by_bioc.txt | \
#     xargs grep -Ern --exclude-dir={.git,data} 'BiocInstaller|biocLite' > $BIOC/$folder/${i}_BiocMaintained_lines.txt
# done

