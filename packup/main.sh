#!/usr/bin/env bash

# Compress a list of files or directories using 7z tagging them with
# the hostname and date. The file extension is also stripped and
# replaced with .7z.

compress() {
    if [ -z "${1}" ]
        then echo "A file or directory must be supplied!"
            return
        elif [ ! -e "${1}" ]
            then echo "The file '${1}' does not exist! Nothing done."
            return
    fi

    theDate=$(date +"%m%d%y")
    base=$(basename -- "${1}")
    out="${base%.*}-$(hostname)-${theDate}.7z"

    if [ -e "${out}" ]
        then echo "The output file ${out} already exists! Nothing done."
             return
        else echo "---------------------------------"
             7z a "${out}" "${1}"
             echo "---------------------------------"
             echo "${1} compressed to ${out}"
    fi
}

if [ $# -eq 0 ]
    then echo "A file must be provided."
    else for x in "${@}"; do
            echo; compress ${x}; done
fi
