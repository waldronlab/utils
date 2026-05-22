# utils

Utility shell scripts used for Bioconductor maintenance workflows.

Most scripts assume a local Bioconductor working tree rooted at `~/bioc` and SSH access to:

- `git.bioconductor.org`
- `github.com:Bioconductor/*`

## Repository contents

### Environment setup

- `setBIOC.sh`  
  Exports shared variables used by other scripts (`BIOC`, `BBS_HOME`, `PYTHONPATH`, `GIST_FOLDER`).

### Package scanning and migration helpers

- `find_keywords.sh`  
  Scans source files for legacy BiocInstaller/biocLite keywords.
- `find_list_packages.sh [software|data-experiment|workflows]`  
  Builds package lists (saved in the gist folder) based on keyword matches.
- `find_valid.sh [packages] [search|line|package]`  
  Inspects commit history for `valid`/`biocVersion` updates in selected packages.
- `replace_biocLite.sh`  
  Rewrites legacy `BiocInstaller`/`biocLite` usage to `BiocManager` calls in the current package directory.
- `replace_alt_keywords.sh`  
  Rewrites alternate legacy helpers (for example `biocinstallRepos`, `biocValid`, `biocVersion`) to `BiocManager` equivalents.
- `fix_repos.sh <pkg_type> <replace|reset|diff|push|status> [packages] [commit_message]`  
  Runs bulk actions across package repositories (replace, reset, inspect, commit/push, status).

### Repository cloning helpers

- `clone_git.sh <package>`  
  Clones a Bioconductor package from GitHub and adds the Bioconductor git remote as `upstream`.
- `clone_repos.sh <branch>`  
  Uses the Bioconductor manifest to clone/pull many package repositories for a branch.
- `clone_check.sh <package>`  
  Clones one package from `git.bioconductor.org` and runs keyword scanning.

### Review, testing, and release utilities

- `biocreview.sh <package_dir>`  
  Runs package build/check/BiocCheck using local aliases from `~/.bash_aliases`.
- `testplatforms.sh [r-version]`  
  Builds and checks `BiocManager` against one or more local R builds (defaults: `4-4`, `4-5`, `devel`).
- `TestBiocManager.sh`  
  Builds/checks `BiocManager` across local old/release/devel R setups.
- `anvil_test_all.sh`  
  Builds/checks AnVIL packages (`AnVILBase`, `AnVIL`, `AnVILGCP`, `AnVILAz`) using a local R install.
- `version_bump.sh`  
  Increments the patch component in `DESCRIPTION` (`Version:` line), commits the change.
- `tag_release.sh`  
  Example commands for manual git tag creation/push.
- `dock.sh <release|tag>`  
  Starts a Bioconductor Docker image with host library mounts.

## Basic usage

Run scripts from your Bioconductor working directory context:

```bash
bash /home/runner/work/utils/utils/find_list_packages.sh software
bash /home/runner/work/utils/utils/fix_repos.sh software replace
bash /home/runner/work/utils/utils/testplatforms.sh 4-5
```

Some scripts source `./utils/setBIOC.sh`, so they expect to run from a directory where `utils/` is a direct child (commonly `~/bioc`).
