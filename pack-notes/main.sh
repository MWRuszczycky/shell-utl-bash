#!/usr/bin/env bash

# Compress the ~/Documents/notes directory to a 7z-archive excluding
# the build directories. The compressed archive is saved to the
# desktop. Decompress & rebuild ~/Documents/notes with unpack-notes.

# ===================================================================
# Global paths

notesPath="${HOME}/Documents/notes"
outPath="${HOME}/Desktop"

# ===================================================================
# Main script

archiveName="${outPath}/notes-$(hostname)-$(date +%y%m%d).7z"

if [ -e ${archiveName} ]; then
    echo -e "${archiveName} already exists.\nAborting."
    exit 1
fi

7z a -xr!build/ "${archiveName}" "${notesPath}"
