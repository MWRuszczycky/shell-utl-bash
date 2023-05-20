#!/usr/bin/env bash

# Unpacks and rebuilds the ~/Documents/notes directory from a
# compressed archive generated using pack-notes or packup.

# ===================================================================
# Global paths settings

notesHome="${HOME}/Documents"
archive="${1}"

# ===================================================================
# Procedures

makeOrphan() {
    local orphan=$( mktemp -d --tmpdir="${2}" "orphan-build-XXXXXX" )
    echo "  old build orphaned as ${orphan#${PWD}/}"
    mv ${1}/* "${orphan}"
}

moveBuilds() {
    for x in $( find ${1} -type d -name "build" ); do
        local sourcePath="${x%/build}"
        local buildPath="${sourcePath#${notesHome}/notes}"
        local targetPath="${2}${buildPath}"

        echo -n "Moving build from ${buildPath} .. "

        if [ -e "${targetPath}/build" ]; then
            echo -e "\e[38;5;214malready exists in new notes\e[0m"
            makeOrphan ${x} ${3}

        elif [ ! -d "${targetPath}" ]; then
            echo -e "\e[38;5;214mmissing directory in new notes\e[0m"
            makeOrphan ${x} ${3}

        else
            mv ${x} ${targetPath}
            echo -e "\e[32mdone\e[0m"
        fi
    done
}

updateBuilds() {
    for x in $( find ${1} -type f -name "builder.sh" ); do
        bash ${x}
    done
}

# ===================================================================
# Main script

echo -e "\e[0mUnpacking notes archive: ${archive}"

if [ -z ${archive} ]; then
    echo -e "Archive required.\nAborting."
    exit 1

elif [ -d "${notesHome}/notes" ]; then
    bufferPath=$( mktemp -d --tmpdir="${PWD}" "notes-buffer-XXXXXX" )
    orphanPath="${bufferPath}/orphans"

    mkdir "${orphanPath}"
    7z x "${archive}" -o"${bufferPath}"
    moveBuilds "${notesHome}/notes/content" "${bufferPath}/notes" "${orphanPath}"
    trash "${notesHome}/notes"
    mv "${bufferPath}/notes" "${notesHome}"
    updateBuilds "${notesHome}/notes/content"

    if [ -z "$( ls -A ${orphanPath})" ];
        then rmdir "${orphanPath}" && rmdir "${bufferPath}"
        else echo -e "\e[38;5;214mThere were orphan builds\e[0m"
    fi

elif [ -e "${notesHome}/notes" ]; then
    echo -e "${notesHome}/notes is not a directory.\nAborting."
    exit 1

else
    7z x "${archive}" -o"${notesHOME}"
fi

trash "${archive}"
