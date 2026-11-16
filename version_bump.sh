#!/bin/bash
#
# Increment the patch (z) component of the Version field in DESCRIPTION and
# commit the change. If CITATION.cff (or citation.cff) exists, its top-level
# `version:` key is updated to match.
#
# usage: version_bump.sh
#
# Environment:
#   VERSION_BUMP_SKIP_CFF=1   leave CITATION.cff untouched (also true/yes)
#
# Portable across GNU and BSD (macOS) sed: edits are written to temp files
# and only applied once every file has been rewritten and verified.

set -euo pipefail

desc_file="DESCRIPTION"

usage() {
    echo "Usage: $0" >&2
    echo "Set VERSION_BUMP_SKIP_CFF=1 to leave CITATION.cff untouched" >&2
    exit 1
}

# Refuse to run if a file has uncommitted (staged or unstaged) edits;
# otherwise they would be swept into the "version bump" commit
require_clean() {
    if ! git diff --quiet -- "$1" || ! git diff --cached --quiet -- "$1"; then
        echo "$1 has uncommitted changes; commit or stash them first" >&2
        exit 1
    fi
}

[[ $# -eq 0 ]] || usage

skip_cff="$(echo "${VERSION_BUMP_SKIP_CFF:-}" | tr '[:upper:]' '[:lower:]')"
case "$skip_cff" in
    1|true|yes) update_cff=false ;;
    ""|0|false|no) update_cff=true ;;
    *)
        echo "Invalid VERSION_BUMP_SKIP_CFF='$VERSION_BUMP_SKIP_CFF' (use 1/true/yes or 0/false/no)" >&2
        exit 1
        ;;
esac

# Prints "false" (exit 0) inside .git/, so compare the output
if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != true ]]; then
    echo "Not inside a git working tree; run from a package repository" >&2
    exit 1
fi

[[ -f "$desc_file" ]] || { echo "Missing $desc_file" >&2; exit 1; }
require_clean "$desc_file"

n_version=$(grep -cE '^Version:' "$desc_file" || true)
if [[ "$n_version" -ne 1 ]]; then
    echo "Expected exactly one Version field in $desc_file, found $n_version" >&2
    exit 1
fi

version_string=$(sed -nE 's/^Version:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' "$desc_file")

if [[ ! "$version_string" =~ ^([0-9]+)[.-]([0-9]+)[.-]([0-9]+)$ ]]; then
    echo "Unsupported version format in $desc_file: '$version_string'" >&2
    exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"
# 10# forces base 10 so values like 07 or 09 are not read as octal
new_patch=$((10#$patch + 1))
new_version="$major.$minor.$new_patch"
new_version_re="${new_version//./\\.}"

echo "==> $new_version ($patch->$new_patch)"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Stage all edits in temp files first so a failure leaves the tree untouched
sed -E "s/^Version:.*$/Version: $new_version/" "$desc_file" > "$tmpdir/desc"
if ! grep -qE "^Version: $new_version_re$" "$tmpdir/desc"; then
    echo "Failed to update version in $desc_file" >&2
    exit 1
fi

files_to_commit=("$desc_file")
cff_file=""

if [[ "$update_cff" == true ]]; then
    # Match the real directory entry: `-f CITATION.cff` is true for
    # citation.cff on case-insensitive filesystems (macOS), but git is not
    for f in *.cff; do
        if [[ -f "$f" && ( "$f" == CITATION.cff || "$f" == citation.cff ) ]]; then
            cff_file="$f"; break
        fi
    done

    if [[ -n "$cff_file" ]]; then
        require_clean "$cff_file"
        # Only the top-level key (no indentation); nested keys such as
        # preferred-citation/references versions are left alone
        n_cff=$(grep -cE '^version:' "$cff_file" || true)
        if [[ "$n_cff" -eq 0 ]]; then
            echo "Warning: no top-level version field in $cff_file; skipping" >&2
            cff_file=""
        elif [[ "$n_cff" -gt 1 ]]; then
            echo "Multiple top-level version fields in $cff_file" >&2
            exit 1
        else
            # Keep any quoting and trailing comment as-is
            sed -E "s/^version:([[:space:]]*)([\"']?)[^\"'#[:space:]]+([\"']?)(.*)$/version:\1\2$new_version\3\4/" \
                "$cff_file" > "$tmpdir/cff"
            if ! grep -qE "^version:[[:space:]]*[\"']?$new_version_re[\"']?([[:space:]]|$)" "$tmpdir/cff"; then
                echo "Failed to update version in $cff_file" >&2
                exit 1
            fi
            files_to_commit+=("$cff_file")
        fi
    fi
fi

# Apply (cat > preserves file mode and ownership)
cat "$tmpdir/desc" > "$desc_file"
if [[ -n "$cff_file" ]]; then cat "$tmpdir/cff" > "$cff_file"; fi

git add -- "${files_to_commit[@]}"
# Commit only these paths, even if other changes are staged
git commit -m "version bump $new_version" -- "${files_to_commit[@]}"
