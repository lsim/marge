#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUBJECTEXTENSION="coffee"
SUBJECTPATH="./app/coffee/controllers/margeController.${SUBJECTEXTENSION}"
OTHERBRANCH="develop"

OUTPUTFOLDER="${SCRIPT_DIR}/../corpus/test"
ORIGINAL="${OUTPUTFOLDER}/original.${SUBJECTEXTENSION}"
FUTURE1="${OUTPUTFOLDER}/future1.${SUBJECTEXTENSION}"
FUTURE2="${OUTPUTFOLDER}/future2.${SUBJECTEXTENSION}"


COMMIT1="$(git rev-parse ${OTHERBRANCH})"
COMMIT2="HEAD"
ANCESTORCOMMIT="$(git merge-base ${COMMIT1} ${COMMIT2})"

mkdir -p "$OUTPUTFOLDER"
git show "${ANCESTORCOMMIT}:${SUBJECTPATH}" > "$ORIGINAL"
git show "${OTHERBRANCH}:${SUBJECTPATH}" > "$FUTURE1"
cat "$SUBJECTPATH" > "$FUTURE2"

ATOMPATH="${SCRIPT_DIR}/../binaries/Atom.app/Contents/MacOS/Atom"

"$(${ATOMPATH} app ${ORIGINAL} ${FUTURE1} ${FUTURE2})"
