#!/bin/sh

# Compress a list of files or directories using 7z tagging them with
# the hostname and date. The file extension is also stripped and
# replaced with .7z.

doCompress() {
    if [ -z "${1}" ]
        then echo "A file or directory must be supplied!"
            return
        elif [ ! -e "${1}" ]
            then echo "The file '${1}' does not exist! Nothing done."
            return
    fi

    DATE=$(date +"%m%d%y")
    BASE=$(basename -- "${1}")
    OUTFILE="${BASE%.*}-$(hostname)-${DATE}.7z"

    if [ -e "${OUTFILE}" ]
        then echo "The output file ${OUTFILE} already exists! Nothing done."
             return
        else echo "---------------------------------"
             7z a "$OUTFILE" "${1}"
             echo "---------------------------------"
             echo "${1} compressed to ${OUTFILE}"
    fi
}

if [ $# -eq 0 ]
    then echo "A file must be provided."
    else for fn in "${@}"
             do echo
                doCompress $fn
             done
fi
