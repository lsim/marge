#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="${SCRIPT_DIR}/marge.log"

echo "arguments: ${@:1}" >> "$LOG_FILE" 2>&1

${SCRIPT_DIR}/../dist/MacOS64/marge.app/Contents/MacOS/node-webkit "${SCRIPT_DIR}/../dist/MacOS64/marge.app/Contents/Resources/app.nw" "${@:1}" >> "$LOG_FILE" 2>&1
