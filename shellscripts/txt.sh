#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJECTEXTENSION="txt"
SUBJECTPATH="./app/coffee/controllers/margeController.${SUBJECTEXTENSION}"
OTHERBRANCH="develop"

OUTPUTFOLDER="corpus/txt"
ORIGINAL="${OUTPUTFOLDER}/original.txt"
FUTURE1="${OUTPUTFOLDER}/future1.txt"
FUTURE2="${OUTPUTFOLDER}/future2.txt"

ATOMPATH="${SCRIPT_DIR}/../binaries/Atom.app/Contents/MacOS/Atom"

${ATOMPATH} app "${ORIGINAL}" "${FUTURE1}" "${FUTURE2}"
