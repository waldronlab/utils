# example tagging workflow
git tag -l
# git show v1.30.23 # previous tag
git tag -a v1.30.24 -m "CRAN Release v1.30.24"
git push origin v1.30.24

