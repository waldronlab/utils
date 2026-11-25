#!/bin/bash
#
# Page through commits with `git show`, oldest first, starting at a given
# commit (inclusive) and ending at HEAD or a given ref. Each commit opens in
# its own pager; press `q` to advance to the next one, Ctrl-C to stop.
#
# usage: git_page.sh [-1] <start-commit> [end-ref]
#
#   -1   show all commits in a single pager (git log -p) instead of one
#        pager per commit; in less, use /^commit then n/N to jump
#
# examples:
#   git_page.sh d962d34
#   git_page.sh d962d34 origin/devel
#   git_page.sh -1 d962d34

set -euo pipefail

usage() {
    sed -n '3,15p' "$0" | sed -e 's/^#//' -e 's/^ //'
    exit "${1:-1}"
}

single=0
if [[ "${1:-}" == "-1" ]]; then
    single=1
    shift
fi
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage 0
[[ $# -lt 1 || $# -gt 2 ]] && usage

start="$1"
end="${2:-HEAD}"

git rev-parse --verify --quiet "${start}^{commit}" >/dev/null ||
    { echo "error: '$start' is not a valid commit" >&2; exit 1; }
git rev-parse --verify --quiet "${end}^{commit}" >/dev/null ||
    { echo "error: '$end' is not a valid commit" >&2; exit 1; }

# Include the start commit itself; a root commit has no parent to exclude.
if git rev-parse --verify --quiet "${start}^" >/dev/null; then
    range=("${start}^..${end}")
else
    range=("$end")
fi

if (( single )); then
    exec git log -p --reverse "${range[@]}"
fi

mapfile -t commits < <(git rev-list --reverse "${range[@]}")
(( ${#commits[@]} )) || { echo "no commits in range" >&2; exit 1; }

# git defaults LESS to FRX; F makes less exit when a commit fits on one
# screen, which skips past short commits. Drop F so every commit pauses.
LESS="${LESS:-RX}"
export LESS="${LESS//F/}"

n=${#commits[@]}
i=0
for c in "${commits[@]}"; do
    i=$((i + 1))
    printf '[%d/%d] %s\n' "$i" "$n" "$(git log -1 --format='%h %s' "$c")" >&2
    git show "$c"
done
