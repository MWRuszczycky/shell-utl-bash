#!/usr/bin/env bash

# Unpacks and rebuilds the ~/Documents/notes directory from a
# compressed archive generated using pack-notes or packup.

# ===================================================================
# Global paths settings

notesHome="${HOME}/Documents"
notesIndex="${HOME}/Documents/notes/index.html"
archive="${1}"

# ===================================================================
# Procedures

makeOrphan() {
    local orphan=$( mktemp -d --tmpdir="${2}" "orphan-build-XXXXXX" )
    echo "  old build orphaned as ${orphan#${PWD}/}"
    mv ${1}/* "${orphan}"
}

# Move the old builds from the old notes to the new notes in the
# temporary buffer directory.
# Arg 1: Old notes directory with the previous builds.
# Arg 2: Buffer directory with the new notes but no builds.
# Arg 3: Orphan directory in the buffer directory.
# When this finishes, the new notes in the buffer will contain the
# builds from the old notes. Any builds that could not be moved will
# be orphaned in the orphan directory of the buffer.
moveBuilds() {
    for x in $( find ${1} -type d -name "build" ); do
        # Create path (targetPath) for the build in the buffer mirror
        # that in the old notes directory.
        local sourcePath="${x%/build}"
        local buildPath="${sourcePath#${notesHome}/notes}"
        local targetPath="${2}${buildPath}"

        echo -n "Moving build from ${buildPath} .. "

        # Attempt to move the build to the buffer. This will fail if
        # (1) The new notes already have the build being moved.
        #     Should not happend if notes packaged correctly.
        # (2) The new notes do not have a directory for the build.
        #     May happen if notes have been deleted in the new notes.
        # If this happens, the old build is an orphan and moved to
        # the orphan directory in the buffer.
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
    rm -r "${notesHome}/notes"
    mv "${bufferPath}/notes" "${notesHome}"
    updateBuilds "${notesHome}/notes/content"

    if [ -z "$( ls -A ${orphanPath} )" ];
        then rmdir "${orphanPath}" && rmdir "${bufferPath}"
        else echo -e "\e[38;5;214mThere were orphan builds\e[0m"
    fi

elif [ -e "${notesHome}/notes" ]; then
    echo -e "${notesHome}/notes is not a directory.\nAborting."
    exit 1

else
    7z x "${archive}" -o"${notesHOME}"
fi

# On Windows, we need to use Markdown in the main index
# On Linux, we need to use HTML in teh main index
echo -e "updating index "
if [ "${OSTYPE}" = "msys" ]; then
    echo "for windows"
    sed -i 's/\.html/\.md/' ${notesIndex}
else
    echo "for linux"
    sed -i "s/\.md/\.html/" ${notesIndex}
fi

rm "${archive}"
