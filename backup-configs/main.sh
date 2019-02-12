#!/bin/sh

TODAY=$(date +"%m%d%y")
TEMPDIR="configs-$(hostname)-$TODAY"

declare -a TOBACKUP=( "$HOME/.bashrc"
                      "$HOME/.bash_profile"
                      "$HOME/.config/ls/colors"
                      "$HOME/.Xdefaults"
                      "$HOME/.gitconfig"
                      "$HOME/.xmobarrc"
                      "$HOME/.Xmodmap"
                      "$HOME/.xmonad/xmonad.hs"
                    )

listConfigsToBackup() {
    echo "Configuration files to backup:"
    if [ -n "${1}" ]
       then for c in $1
            do echo "  ${c}"
            done
       else echo "  No files to backup."
    fi
}

checkOutputExists() {
    if [ -f "${1}.7z" ];
       then echo "The target ${1}.7z already exists. Aborting!"
            exit 1
    fi
}

createTempDirectory() {
    echo "Trying to create directory ${1} for backups..."
    if [ -d "${1}" ];
       then echo "...but it already exists. Aborting!"
            exit 1
       else mkdir "${1}"
            echo "...directory ${1} successfully created"
            echo
    fi
}

copyFilesToTemp() {
# First argument is the temp output directory name
# Second argument is the array of config file names
    for fn in $2
        do if [ -f "${fn}" ]
              then echo "Copying ${fn} to ${1}"
                   cp "${fn}" "${1}"
              else echo "The file ${fn} does not exist, so it will be skipped"
           fi
        done
}

checkForMissing() {
    local MISSING=false
    for fn in $1
        do if [ ! -f "$fn" ]
              then MISSING=true
                   break
           fi
        done
    if [ "$MISSING" = true ]
       then echo "There some missing files."
       else echo "All files copied."
    fi
}

compressTempDirectory() {
    echo
    echo "Compressing ${1} with 7z to ${1}.7z"
    echo "-------------------------------------------------------------------------"
    7z a "${1}.7z" "${1}"
    echo "-------------------------------------------------------------------------"
}

if [ "${1}" = "-l" -o "${1}" = "--list" ]
    then listConfigsToBackup "${TOBACKUP[*]}"
         exit 0
    else checkOutputExists "${TEMPDIR}"
         createTempDirectory "${TEMPDIR}"
         copyFilesToTemp "${TEMPDIR}" "${TOBACKUP[*]}"
         compressTempDirectory "${TEMPDIR}"
         checkForMissing "${TOBACKUP[*]}"
         rm -r "${TEMPDIR}"
fi
