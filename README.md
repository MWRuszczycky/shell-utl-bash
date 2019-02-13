# Bash utility scripts

## Overview

Collection of (half-way decent) Bash utility scripts.

## List of scripts

| Name      | Intended function |
|-----------|-------------------|
| `packup`  | Archives, compresses and tags stuff for backup using 7z. |

## Maintaining and installing scripts on NixOS

Each script should be in its own directory in the repository and written in a file named `main.sh`. The directory name should be the same as the script-command-name. The directory should also contain a `default.nix` file with the following attribute set:
```nix
{ dir         = "directory-command-name"
; version     = "the-version-number"
; description = "short-description-of-what-the-script-does"
; }
```
Be sure to add any new scripts as an attribute in the attribute set in the `default.nix` file in the repository root directory. To install or update a script in the local `.nix-profile`, cd to the repository root directory and run
```sh
$ nix-env -if . -A SCRIPT-DIR ...
```
Where `SCRIPT-DIR` is the directory-command-name of the script to install.
